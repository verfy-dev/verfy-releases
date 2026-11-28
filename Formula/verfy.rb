# Written by scripts/packages.py for each release; do not edit by hand.
class Verfy < Formula
  desc "Lockfile and guard for the MCP tools and commands your AI coding agents use"
  homepage "https://verfy.dev"
  version "0.33.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/verfy-dev/verfy-releases/releases/download/v0.33.0/verfy-macos-arm64.tar.gz"
      sha256 "47bf2648610173048abbee6fdeac1daa75b4f5932c973677651de04110713251"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/verfy-dev/verfy-releases/releases/download/v0.33.0/verfy-linux-x64.tar.gz"
      sha256 "faf70629d086f621ca489bcc26af888fb8595455faa4df70fce4205e3daa1e62"
    end
    on_arm do
      url "https://github.com/verfy-dev/verfy-releases/releases/download/v0.33.0/verfy-linux-arm64.tar.gz"
      sha256 "c4cfa88349dfc2e8bd12cfa22ad49b41c33fa231232410787955df2937409a26"
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
