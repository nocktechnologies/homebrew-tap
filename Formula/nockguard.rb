class Nockguard < Formula
  desc "MCP firewall for AI agent fleets: per-agent tool policies and audit trails"
  homepage "https://github.com/nocktechnologies/nockguard"
  url "https://github.com/nocktechnologies/nockguard/archive/refs/tags/v0.10.0.tar.gz"

  sha256 "3542821e77af4d6e7c09294b5ebca6fd6afd50338afb92e5c79a7d7abcf7a92e"
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
