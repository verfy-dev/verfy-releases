# Written by scripts/packages.py for each release; do not edit by hand.
class Verfy < Formula
  desc "Lockfile and guard for the MCP tools and commands your AI coding agents use"
  homepage "https://verfy.dev"
  version "0.25.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/verfy-dev/verfy-releases/releases/download/v0.25.0/verfy-macos-arm64.tar.gz"
      sha256 "5ca27d39f4bc5e2e4438f0ae625ef741d82e59501d7cfeb10cc85a792cf98372"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/verfy-dev/verfy-releases/releases/download/v0.25.0/verfy-linux-x64.tar.gz"
      sha256 "8fe3a509d421639dc505916c97ca786289ba604ba9444ec13ed7b7de5d482daa"
    end
    on_arm do
      url "https://github.com/verfy-dev/verfy-releases/releases/download/v0.25.0/verfy-linux-arm64.tar.gz"
      sha256 "9d29c661dcc3f3ec6d1b9e5e39a76998d4df0619fdf8c9e9e43f75609240b243"
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
