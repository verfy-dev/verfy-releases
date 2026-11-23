# Written by scripts/packages.py for each release; do not edit by hand.
class Verfy < Formula
  desc "Lockfile and guard for the MCP tools and commands your AI coding agents use"
  homepage "https://verfy.dev"
  version "0.26.4"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/verfy-dev/verfy-releases/releases/download/v0.26.4/verfy-macos-arm64.tar.gz"
      sha256 "799cd3fccab7f469513388b1bed3e5c7a28b364f45b1011db639020e5f95526f"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/verfy-dev/verfy-releases/releases/download/v0.26.4/verfy-linux-x64.tar.gz"
      sha256 "93cba4b6a18bbfe60f12890215dc8739908f5be1e96bc290e28bf81ef73e905b"
    end
    on_arm do
      url "https://github.com/verfy-dev/verfy-releases/releases/download/v0.26.4/verfy-linux-arm64.tar.gz"
      sha256 "ee8f83b9d5aeaef5119838c28c9093304ea2adac23d30c4d4c611bbc3845487f"
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
