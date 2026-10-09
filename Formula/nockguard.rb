class Nockguard < Formula
  desc "MCP firewall for AI agent fleets: per-agent tool policies and audit trails"
  homepage "https://github.com/nocktechnologies/nockguard"
  url "https://github.com/nocktechnologies/nockguard/archive/refs/tags/v0.4.0.tar.gz"

  sha256 "3f3763245e3b3734c447608585792e5ab403a59168343f552422d0d49e8417da"
  license "MIT"
  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w"), "./cmd/nockguard"
  end

  test do
    assert_match "nockguard v#{version}", shell_output("#{bin}/nockguard version")
  end
end
