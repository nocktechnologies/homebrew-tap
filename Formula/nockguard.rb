class Nockguard < Formula
  desc "MCP firewall for AI agent fleets: per-agent tool policies and audit trails"
  homepage "https://github.com/nocktechnologies/nockguard"
  url "https://github.com/nocktechnologies/nockguard/archive/refs/tags/v0.2.0.tar.gz"

  sha256 "3154016840333d10c0de13fb70b751a9ff7face90421b5ff647f93a3820540a1"
  license "MIT"
  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w"), "./cmd/nockguard"
  end

  test do
    assert_match "nockguard v#{version}", shell_output("#{bin}/nockguard version")
  end
end
