# Written by scripts/packages.py for each release; do not edit by hand.
class Verfy < Formula
  desc "Lockfile and guard for the MCP tools and commands your AI coding agents use"
  homepage "https://verfy.dev"
  version "0.28.1"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/verfy-dev/verfy-releases/releases/download/v0.28.1/verfy-macos-arm64.tar.gz"
      sha256 "7ba1498f86d637df0786aed74c39a8fd88906f1bbdfe92e07fb64749c195318c"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/verfy-dev/verfy-releases/releases/download/v0.28.1/verfy-linux-x64.tar.gz"
      sha256 "685c25c14e249ea3d3045e66b4049418652dbbbebef74d78bb6e2127033edde2"
    end
    on_arm do
      url "https://github.com/verfy-dev/verfy-releases/releases/download/v0.28.1/verfy-linux-arm64.tar.gz"
      sha256 "dfbe2c80cb513bdbc46353c9df94e0be4daca835fb7519faa034929907a9184c"
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
