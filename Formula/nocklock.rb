class Nocklock < Formula
  desc "Fence your AI agents — control secrets, filesystem, and network access"
  homepage "https://github.com/nocktechnologies/nocklock"
  url "https://github.com/nocktechnologies/nocklock/archive/refs/tags/v0.4.0.tar.gz"

  sha256 "d43cb4deffd5a466841c867ed15ecc58ac2428598eae6270ac21dbb449cc05ef"
  license "MIT"
  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w -X github.com/nocktechnologies/nocklock/internal/version.Version=#{version}"), "./cmd/nocklock"
  end

  test do
    assert_match "NockLock v#{version}", shell_output("#{bin}/nocklock version")
  end
end
