class Nocklock < Formula
  desc "Fence your AI agents: control secrets, filesystem, and network access"
  homepage "https://github.com/nocktechnologies/nocklock"
  url "https://github.com/nocktechnologies/nocklock/archive/refs/tags/v1.0.0.tar.gz"

  sha256 "ec96f2e4058e71966a81cb304969285ffe67d0e7dcc134433c6c311a8ad6d52e"
  license "MIT"
  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w -X github.com/nocktechnologies/nocklock/internal/version.Version=#{version}"), "./cmd/nocklock"
  end

  test do
    assert_match "NockLock v#{version}", shell_output("#{bin}/nocklock version")
  end
end
