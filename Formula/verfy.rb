# Written by scripts/packages.py for each release; do not edit by hand.
class Verfy < Formula
  desc "Lockfile and guard for the MCP tools and commands your AI coding agents use"
  homepage "https://verfy.dev"
  version "0.27.1"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/verfy-dev/verfy-releases/releases/download/v0.27.1/verfy-macos-arm64.tar.gz"
      sha256 "4c3b404ddc0b7e938dd37ebba379fac4f833f315915c8c93de291a58038ae5b8"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/verfy-dev/verfy-releases/releases/download/v0.27.1/verfy-linux-x64.tar.gz"
      sha256 "d606d07e7f6173135895d01c522d98d008e01bf9be6ef077926e781134d1e78c"
    end
    on_arm do
      url "https://github.com/verfy-dev/verfy-releases/releases/download/v0.27.1/verfy-linux-arm64.tar.gz"
      sha256 "afd84f3056ee6ed02dbcb06901dc1076de64d08c607fd4c7b1c8e278c2880915"
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
