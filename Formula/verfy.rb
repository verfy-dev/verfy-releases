# Written by scripts/packages.py for each release; do not edit by hand.
class Verfy < Formula
  desc "Lockfile and guard for the MCP tools and commands your AI coding agents use"
  homepage "https://verfy.dev"
  version "0.32.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/verfy-dev/verfy-releases/releases/download/v0.32.0/verfy-macos-arm64.tar.gz"
      sha256 "95953a6937fc2919b2426b63326e3520aae796ea63e24ee0b1109597c929011c"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/verfy-dev/verfy-releases/releases/download/v0.32.0/verfy-linux-x64.tar.gz"
      sha256 "469cf83c1c8d88987e017d15bde5e2e2d73424bf648ba7be3aef22a30d0900a4"
    end
    on_arm do
      url "https://github.com/verfy-dev/verfy-releases/releases/download/v0.32.0/verfy-linux-arm64.tar.gz"
      sha256 "862e5ff0ca6956e02f48aad6d9b6339a65dd0bc763500f406d10ec282a7af932"
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
