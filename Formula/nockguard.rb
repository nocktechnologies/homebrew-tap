class Nockguard < Formula
  desc "MCP firewall for AI agent fleets: per-agent tool policies and audit trails"
  homepage "https://github.com/nocktechnologies/nockguard"
  url "https://github.com/nocktechnologies/nockguard/archive/refs/tags/v0.3.0.tar.gz"

  sha256 "4fd7753915dd91e075ac23ac891a0c46a3265bad79600245d9a3196ac5bbbd56"
  license "MIT"
  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w"), "./cmd/nockguard"
  end

  test do
    assert_match "nockguard v#{version}", shell_output("#{bin}/nockguard version")
  end
end
