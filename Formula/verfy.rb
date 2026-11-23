# Written by scripts/packages.py for each release; do not edit by hand.
class Verfy < Formula
  desc "Lockfile and guard for the MCP tools and commands your AI coding agents use"
  homepage "https://verfy.dev"
  version "0.26.6"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/verfy-dev/verfy-releases/releases/download/v0.26.6/verfy-macos-arm64.tar.gz"
      sha256 "be2478e12e0248c405f6b04db161c8f3937b4db094de23ee1ad6d2f183842c41"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/verfy-dev/verfy-releases/releases/download/v0.26.6/verfy-linux-x64.tar.gz"
      sha256 "b7f8814d82a0b63ae6bfdc5a1b7fc9019d2e07631ca368ab7ed9e141cd616d62"
    end
    on_arm do
      url "https://github.com/verfy-dev/verfy-releases/releases/download/v0.26.6/verfy-linux-arm64.tar.gz"
      sha256 "e868790f8542cdd977907d8ef30bb370dc5e1be941b5849afdfd55664ef9a9de"
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
