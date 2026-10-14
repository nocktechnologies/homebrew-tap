class Nockguard < Formula
  desc "MCP firewall for AI agent fleets: per-agent tool policies and audit trails"
  homepage "https://github.com/nocktechnologies/nockguard"
  url "https://github.com/nocktechnologies/nockguard/archive/refs/tags/v0.7.0.tar.gz"

  sha256 "c7016d482a56dc3fdb42d0cea88cc769ac7415fa9d1949eb7839326b055f2ff1"
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
