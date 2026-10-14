class Nocklock < Formula
  desc "Fence your AI agents: control secrets, filesystem, and network access"
  homepage "https://github.com/nocktechnologies/nocklock"
  url "https://github.com/nocktechnologies/nocklock/archive/refs/tags/v0.10.0.tar.gz"

  sha256 "c12fe6f2ffa57801435ee4119dcbabf87874bb57b988352bda428692c71c3f80"
  license "MIT"
  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w -X github.com/nocktechnologies/nocklock/internal/version.Version=#{version}"), "./cmd/nocklock"
  end

  test do
    assert_match "NockLock v#{version}", shell_output("#{bin}/nocklock version")
  end
end
