class Nockguard < Formula
  desc "MCP firewall for AI agent fleets: per-agent tool policies and audit trails"
  homepage "https://github.com/nocktechnologies/nockguard"
  url "https://github.com/nocktechnologies/nockguard/archive/refs/tags/v0.8.0.tar.gz"

  sha256 "765b42bf64454a11748cb03967a4c88ab4e0715f78d48db98d37f39dc9bc11d6"
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
