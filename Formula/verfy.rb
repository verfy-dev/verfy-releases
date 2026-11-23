# Written by scripts/packages.py for each release; do not edit by hand.
class Verfy < Formula
  desc "Lockfile and guard for the MCP tools and commands your AI coding agents use"
  homepage "https://verfy.dev"
  version "0.26.5"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/verfy-dev/verfy-releases/releases/download/v0.26.5/verfy-macos-arm64.tar.gz"
      sha256 "8592b61865b12d4fe41991e88e33110b32fadca80dc6bd75bbf199fdafba7490"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/verfy-dev/verfy-releases/releases/download/v0.26.5/verfy-linux-x64.tar.gz"
      sha256 "942d84ffcc358b3d5ade91cce79cecb62d18505b795183030e157a5d2f7ee6ec"
    end
    on_arm do
      url "https://github.com/verfy-dev/verfy-releases/releases/download/v0.26.5/verfy-linux-arm64.tar.gz"
      sha256 "e61333d585fd269abdacfcc2f1d76c89bf00ff6640d035e42c7b09d52976bca4"
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
