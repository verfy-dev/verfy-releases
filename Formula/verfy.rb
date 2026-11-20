# Written by scripts/packages.py for each release; do not edit by hand.
class Verfy < Formula
  desc "Lockfile and guard for the MCP tools and commands your AI coding agents use"
  homepage "https://verfy.dev"
  version "0.26.2"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/verfy-dev/verfy-releases/releases/download/v0.26.2/verfy-macos-arm64.tar.gz"
      sha256 "0bfdaf22b5eb2e7f7d7a64b17dd1e3e77ed26370a09975ef5ff858b9c93d6111"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/verfy-dev/verfy-releases/releases/download/v0.26.2/verfy-linux-x64.tar.gz"
      sha256 "21a9bf08f2db6480d1f97813f7f0cf96420b71ced329705268b41a16e3d24637"
    end
    on_arm do
      url "https://github.com/verfy-dev/verfy-releases/releases/download/v0.26.2/verfy-linux-arm64.tar.gz"
      sha256 "d97bd18bd3040f89e3942258920cfe97da96e49af3052e2a72b7baef0eaedd90"
    end
  end

  def install
    # the standalone build: the verfy program with the Python it carries, kept together
    libexec.install Dir["*"]
    bin.write_exec_script libexec/"verfy"
  end

  test do
    assert_equal "verfy #{version}", shell_output("#{bin}/verfy --version").strip
    assert_match "chain verified", shell_output("VERFY_HOME=#{testpath}/home #{bin}/verfy demo")
  end
end
