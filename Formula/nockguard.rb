class Nockguard < Formula
  desc "MCP firewall for AI agent fleets: per-agent tool policies and audit trails"
  homepage "https://github.com/nocktechnologies/nockguard"
  url "https://github.com/nocktechnologies/nockguard/archive/refs/tags/v0.12.0.tar.gz"

  sha256 "964b8536ec4051fc43b4b00fdc71463d15c3307cc054da29b8f27a580c83228f"
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
