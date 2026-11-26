# Written by scripts/packages.py for each release; do not edit by hand.
class Verfy < Formula
  desc "Lockfile and guard for the MCP tools and commands your AI coding agents use"
  homepage "https://verfy.dev"
  version "0.29.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/verfy-dev/verfy-releases/releases/download/v0.29.0/verfy-macos-arm64.tar.gz"
      sha256 "fb7a38d47df3b27115293f73ea9a7a3f0497eab7691c9c9311a8aa909844c0f2"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/verfy-dev/verfy-releases/releases/download/v0.29.0/verfy-linux-x64.tar.gz"
      sha256 "b20d674607cbc69a6ecc19f8fa7a58ba87c7b8543f20702ab2daa33d89d28743"
    end
    on_arm do
      url "https://github.com/verfy-dev/verfy-releases/releases/download/v0.29.0/verfy-linux-arm64.tar.gz"
      sha256 "0cd8554f93d93bc9f127799bf4ea649d4fbe3facc4d2ee27450bcc306ec50f1e"
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
