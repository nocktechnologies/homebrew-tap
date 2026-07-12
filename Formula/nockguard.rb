class Nockguard < Formula
  desc "MCP firewall for AI agent fleets — per-agent tool policies and audit trails"
  homepage "https://github.com/nocktechnologies/nockguard"
  url "https://github.com/nocktechnologies/nockguard/archive/refs/tags/v0.1.0.tar.gz"

  sha256 "505096d19d66b259603c865717cb3d219f94cd02170e3bf383f0a286465cf0ee"
  license "MIT"
  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w"), "./cmd/nockguard"
  end

  test do
    assert_match "nockguard v#{version}", shell_output("#{bin}/nockguard version")
  end
end
