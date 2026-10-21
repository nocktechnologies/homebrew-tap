class Nocklock < Formula
  desc "Fence your AI agents: control secrets, filesystem, and network access"
  homepage "https://github.com/nocktechnologies/nocklock"
  url "https://github.com/nocktechnologies/nocklock/archive/refs/tags/v0.13.1.tar.gz"

  sha256 "c488d1f480d2c214f8de115fbfb567a8cee5c837f75620fe5355cc7379ce3f76"
  license "MIT"
  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w -X github.com/nocktechnologies/nocklock/internal/version.Version=#{version}"), "./cmd/nocklock"
  end

  test do
    assert_match "NockLock v#{version}", shell_output("#{bin}/nocklock version")
  end
end
