# Written by scripts/packages.py for each release; do not edit by hand.
class Verfy < Formula
  desc "Lockfile and guard for the MCP tools and commands your AI coding agents use"
  homepage "https://verfy.dev"
  version "0.27.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/verfy-dev/verfy-releases/releases/download/v0.27.0/verfy-macos-arm64.tar.gz"
      sha256 "8a988d803dd07c08b3547e6c838b2a977f1213b193d0c154f943164a17d1a4dc"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/verfy-dev/verfy-releases/releases/download/v0.27.0/verfy-linux-x64.tar.gz"
      sha256 "066dc4f140e12dfc13527df2bf212e0fa34792076272d6e3d16da00d9d8170de"
    end
    on_arm do
      url "https://github.com/verfy-dev/verfy-releases/releases/download/v0.27.0/verfy-linux-arm64.tar.gz"
      sha256 "6c22b8f9d2c39e731220ddc79da58daada3afba85df6ede1018a77ba534446d7"
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
