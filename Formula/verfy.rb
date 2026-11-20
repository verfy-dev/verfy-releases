# Written by scripts/packages.py for each release; do not edit by hand.
class Verfy < Formula
  desc "Lockfile and guard for the MCP tools and commands your AI coding agents use"
  homepage "https://verfy.dev"
  version "0.26.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/verfy-dev/verfy-releases/releases/download/v0.26.0/verfy-macos-arm64.tar.gz"
      sha256 "a670d234bf5664ce500c5acfa2efe847088f43e6efa240302a996d50edda751f"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/verfy-dev/verfy-releases/releases/download/v0.26.0/verfy-linux-x64.tar.gz"
      sha256 "3b7e295382c1089c0be7d234200399d5b4d03993b385c7b7551453fbc9391b63"
    end
    on_arm do
      url "https://github.com/verfy-dev/verfy-releases/releases/download/v0.26.0/verfy-linux-arm64.tar.gz"
      sha256 "66ffcb9f0271cb027a0531057fba5ea6b51129324fcc5515b10f692d11bb2887"
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
