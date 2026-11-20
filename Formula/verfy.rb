# Written by scripts/packages.py for each release; do not edit by hand.
class Verfy < Formula
  desc "Lockfile and guard for the MCP tools and commands your AI coding agents use"
  homepage "https://verfy.dev"
  version "0.26.1"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/verfy-dev/verfy-releases/releases/download/v0.26.1/verfy-macos-arm64.tar.gz"
      sha256 "9211c8c8caca917ac8300bbfdd14c5c907b7d2ad1202781a0218531968e2eb8d"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/verfy-dev/verfy-releases/releases/download/v0.26.1/verfy-linux-x64.tar.gz"
      sha256 "e8d12ab44e2a9ab22598c54afb263381d0590cd14ee30d6ad6339d350e1c9569"
    end
    on_arm do
      url "https://github.com/verfy-dev/verfy-releases/releases/download/v0.26.1/verfy-linux-arm64.tar.gz"
      sha256 "2146cfb24e3c78faac127a426971ec99c9ae69e2dea2cc76265db0a3b200b081"
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
