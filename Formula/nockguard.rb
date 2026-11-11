class Nockguard < Formula
  desc "MCP firewall for AI agent fleets: per-agent tool policies and audit trails"
  homepage "https://github.com/nocktechnologies/nockguard"
  url "https://github.com/nocktechnologies/nockguard/archive/refs/tags/v0.12.1.tar.gz"

  sha256 "3b940d8680ed2523768fbe683ac0356dcf1b28556e9109882b71637da6b01eb4"
  license "MIT"
  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w"), "./cmd/nockguard"
    system "go", "build", *std_go_args(ldflags: "-s -w", output: bin/"nockguard-wall"), "./cmd/nockguard-wall"
  end

  test do
    assert_match "nockguard v#{version}", shell_output("#{bin}/nockguard version")
    assert_predicate bin/"nockguard-wall", :executable?
  end
end
