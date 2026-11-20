# Written by scripts/packages.py for each release; do not edit by hand.
class Verfy < Formula
  desc "Lockfile and guard for the MCP tools and commands your AI coding agents use"
  homepage "https://verfy.dev"
  version "0.26.3"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/verfy-dev/verfy-releases/releases/download/v0.26.3/verfy-macos-arm64.tar.gz"
      sha256 "6e62ac899fdabe5d056cc98be8218b381851aa7fb207848036b183ba11e05b68"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/verfy-dev/verfy-releases/releases/download/v0.26.3/verfy-linux-x64.tar.gz"
      sha256 "4d790dc1b38dde123369e23df6c376fa038e3f4dcf3d7670a42ef1de9c56d191"
    end
    on_arm do
      url "https://github.com/verfy-dev/verfy-releases/releases/download/v0.26.3/verfy-linux-arm64.tar.gz"
      sha256 "37fbd4a0159ebdc30a497365e100f65aa620684b4d3ba72b5fd9e2e76e786655"
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
