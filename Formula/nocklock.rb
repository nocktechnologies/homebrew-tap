class Nocklock < Formula
  desc "Fence your AI agents — control secrets, filesystem, and network access"
  homepage "https://github.com/nocktechnologies/nocklock"
  url "https://github.com/nocktechnologies/nocklock/archive/refs/tags/v0.1.0.tar.gz"
  
  sha256 "7a6c6fc3b3dd895f21ae1d995faf651fa19e0430dc891c2ff6c455303ccdad9a"  
  license "MIT"
  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w -X github.com/nocktechnologies/nocklock/internal/version.Version=#{version}"), "./cmd/nocklock"
  end

  test do
    assert_match "NockLock v#{version}", shell_output("#{bin}/nocklock version")
  end
end
