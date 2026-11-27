# Written by scripts/packages.py for each release; do not edit by hand.
class Verfy < Formula
  desc "Lockfile and guard for the MCP tools and commands your AI coding agents use"
  homepage "https://verfy.dev"
  version "0.30.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/verfy-dev/verfy-releases/releases/download/v0.30.0/verfy-macos-arm64.tar.gz"
      sha256 "5ad6e29d59247844fc83e0124fac5485374d927ccce7a38f0a2ef9db772fcad3"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/verfy-dev/verfy-releases/releases/download/v0.30.0/verfy-linux-x64.tar.gz"
      sha256 "3859b6ed4c016a4c1f8c6ba1673fbde240e040ea4ab02d5ce7a7433530eb2a8a"
    end
    on_arm do
      url "https://github.com/verfy-dev/verfy-releases/releases/download/v0.30.0/verfy-linux-arm64.tar.gz"
      sha256 "51bf615aa720e2f6dba667d5b5011f4c985fb046999072d53a3e450a44cc6b2a"
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
