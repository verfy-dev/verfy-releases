# Written by scripts/packages.py for each release; do not edit by hand.
class Verfy < Formula
  desc "Lockfile and guard for the MCP tools and commands your AI coding agents use"
  homepage "https://verfy.dev"
  version "0.28.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/verfy-dev/verfy-releases/releases/download/v0.28.0/verfy-macos-arm64.tar.gz"
      sha256 "393719f9b899a8b252fde4489bbd4bc398ea68a0c9312ded4abf16c1ebc7e368"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/verfy-dev/verfy-releases/releases/download/v0.28.0/verfy-linux-x64.tar.gz"
      sha256 "ac7189ded969e813fd897b5605001d42400a5736c99e633db0041ddeb80df822"
    end
    on_arm do
      url "https://github.com/verfy-dev/verfy-releases/releases/download/v0.28.0/verfy-linux-arm64.tar.gz"
      sha256 "f73089d28e8ed3504a686b8dabe28a98ff30393a28261f7b3d4f913d5e4ee1aa"
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
