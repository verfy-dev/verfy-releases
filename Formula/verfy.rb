# Written by scripts/packages.py for each release; do not edit by hand.
class Verfy < Formula
  desc "Lockfile and guard for the MCP tools and commands your AI coding agents use"
  homepage "https://verfy.dev"
  version "0.31.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/verfy-dev/verfy-releases/releases/download/v0.31.0/verfy-macos-arm64.tar.gz"
      sha256 "75b405b346a11a78a8b02f7323e88e33f9b4d3a5842804cd06f0c0f3cfe5404f"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/verfy-dev/verfy-releases/releases/download/v0.31.0/verfy-linux-x64.tar.gz"
      sha256 "f0e335d6d5f717218c4ad58e03cbce2c2a2d23c7b9ff7522083c7d57a7ec6969"
    end
    on_arm do
      url "https://github.com/verfy-dev/verfy-releases/releases/download/v0.31.0/verfy-linux-arm64.tar.gz"
      sha256 "7472b39118f0b1e288702d8d28048f33e864f238466d182be8d62dba7a5698ab"
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
