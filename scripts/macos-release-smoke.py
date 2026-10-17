#!/usr/bin/env python3
"""Exercise installed release binaries on a disposable macOS runner."""

import hashlib
import importlib.util
import json
import os
from pathlib import Path
import shutil
import sqlite3
import subprocess
import sys
import tempfile
from unittest.mock import patch


class QuickstartComplete(Exception):
    """The upstream quickstart assertions passed; its separate demo is next."""


def check_guard(source, evidence):
    binary = shutil.which("nockguard")
    version = subprocess.check_output([binary, "version"], text=True)
    assert version.strip() == f"nockguard {os.environ['GUARD_TAG']}", version
    (evidence / "guard-version.txt").write_text(version)
    subprocess.run([binary, "wall", "--help"], check=True, capture_output=True)
    spec = importlib.util.spec_from_file_location("quickstart", source / "scripts/quickstart-acceptance.py")
    quickstart = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(quickstart)
    real_run = subprocess.run
    builds = 0

    def use_installed(args, **kwargs):
        nonlocal builds
        if args[0] == "go":
            assert args[:3] == ["go", "build", "-o"] and args[4:] == ["./cmd/nockguard"], args
            shutil.copy2(binary, args[3])
            builds += 1
            return subprocess.CompletedProcess(args, 0)
        # All read/deny/signed-trail assertions precede this separate demo.
        if args[1:] == ["keygen", "--agent", "demo"]:
            raise QuickstartComplete
        return real_run(args, **kwargs)

    # Reuse the tagged acceptance code, replacing only its build with installed bytes.
    with patch.object(quickstart.subprocess, "run", use_installed):
        try:
            quickstart.main()
        except QuickstartComplete:
            pass
        else:
            raise AssertionError("upstream quickstart/demo boundary changed")
    assert builds == 1, builds
    (evidence / "guard-smoke.txt").write_text("PASS: installed quickstart allow/deny, signed trail and Wall companion execution\n")


def check_lock(evidence):
    binary = shutil.which("nocklock")
    with tempfile.TemporaryDirectory(prefix="nock-release-smoke-", dir=Path.home()) as scratch:
        root = Path(scratch).resolve()
        project = root / "project"
        project.mkdir(mode=0o700)
        env = dict(os.environ, XDG_CONFIG_HOME=str(root / "config"), XDG_STATE_HOME=str(root / "state"))
        for name in ("config", "state"):
            (root / name).mkdir(mode=0o700)

        def run(label, *args):
            result = subprocess.run([binary, *args], cwd=project, env=env, text=True,
                                    capture_output=True, timeout=120)
            (evidence / f"lock-{label}.txt").write_text(result.stdout + result.stderr)
            print(result.stdout + result.stderr, end="")
            result.check_returncode()
            return result.stdout

        assert run("version", "version").strip() == f"NockLock {os.environ['LOCK_TAG']}"
        run("init", "init")
        doctor = json.loads(run("doctor", "doctor", "--json"))
        assert doctor["verdict"] == "PROTECTED" and doctor["egress_level"] == "SEATBELT", doctor
        assert {b["name"]: b["posture"] for b in doctor["boundaries"]} == {
            name: "enforced" for name in ("filesystem", "signing-key", "syscall", "network", "secrets")
        }, doctor
        verify = json.loads(run("verify", "verify", "--json"))
        checks = {c["fence"]: c for c in verify["checks"]}
        for name in ("filesystem", "network", "secret"):
            assert checks[name]["result"] == "PASS", checks
        assert checks["syscall"]["result"] == "SKIP" and "only implemented on Linux" in checks["syscall"]["detail"], checks
        assert verify["summary"] == {"passed": 3, "failed": 0, "skipped": 1}, verify
        assert "WRAP_OK" in run("wrap", "wrap", "--", "/bin/echo", "WRAP_OK")
        assert "AUDIT: AUTHENTIC" in run("audit", "verify", "--audit", "--require-closed")
        project_key = hashlib.sha256(str(project).encode()).hexdigest()[:16]
        db = root / "state/nocklock" / project_key / "events.db"
        with sqlite3.connect(db.as_uri() + "?mode=ro", uri=True) as connection:
            rows = connection.execute(
                "SELECT detail, entry_sig, session_id FROM events WHERE event_type = 'session_start' ORDER BY id"
            ).fetchall()
        assert rows and all(row[1] for row in rows), "missing signed session rows"
        for detail, _, _ in rows:
            assert json.loads(detail)["egress_level"] == "SEATBELT", detail
        (evidence / "lock-sessions.json").write_text(json.dumps([
            {"session_id": row[2], "egress_level": json.loads(row[0])["egress_level"], "signed": bool(row[1])}
            for row in rows
        ], indent=2) + "\n")
        print("PASS: signed, closed SEATBELT sessions and authentic audit")


if __name__ == "__main__":
    assert sys.platform == "darwin", "This smoke requires a disposable macOS host"
    check_guard(Path(sys.argv[1]).resolve(), Path(sys.argv[2]).resolve())
    check_lock(Path(sys.argv[2]).resolve())
