# Homebrew formula for forecli (the `fore` CLI).
#
# Lives in this repo for review convenience; the canonical copy belongs in a
# tap repo (e.g. https://github.com/foreai-co/homebrew-tap). On every release
# the release workflow rewrites version + per-arch url/sha256 via
# scripts/update-brew-formula.py.
#
# We ship a PyInstaller-built standalone binary per (os, arch), so installs
# don't depend on the user's Python, libexpat, or any transitive Python build
# backend. Windows users download `forecli-<version>-windows-x86_64.exe`
# directly from the tap's GitHub release page (brew doesn't run on Windows).
#
# Install path (for end users):
#   brew tap foreai-co/tap
#   brew install forecli
#   fore skill install      # interactive: copies SKILL.md + (opt-in) guardrails hook
class Forecli < Formula
  desc "CLI for the foreai (uiforeia) platform"
  homepage "https://github.com/foreai-co/foreCLI"
  license "Apache-2.0"
  version "0.1.8"

  # BEGIN binaries — managed by scripts/update-brew-formula.py
  on_macos do
    url "https://github.com/foreai-co/homebrew-tap/releases/download/v0.1.8/forecli-0.1.8-darwin-arm64.tar.gz"
    sha256 "b5d02bf3f772ef19b474ee0cf2784f6bedadc77643b0cb572c375fade2da3196"
  end
  on_linux do
    on_intel do
      url "https://github.com/foreai-co/homebrew-tap/releases/download/v0.1.8/forecli-0.1.8-linux-x86_64.tar.gz"
      sha256 "e27955db7326bba982bf8bfe42d3c5c3d477473ad03c31eb86fb58bc462ea80b"
    end
    on_arm do
      url "https://github.com/foreai-co/homebrew-tap/releases/download/v0.1.8/forecli-0.1.8-linux-arm64.tar.gz"
      sha256 "bd4430df8e645574979da29db22231a9770f2fefbaae0fa68d29ae20381533b0"
    end
  end

  # END binaries

  def install
    bin.install "fore"
  end

  def caveats
    <<~EOS
      `fore` is installed. Please do not hesitate to provide feedback. Safe travels.
    EOS
  end

  test do
    # `fore --help` exits non-zero in `no_args_is_help` mode, so call it
    # explicitly. The output must include the project description.
    assert_match "CLI for the foreai", shell_output("#{bin}/fore --help")
    # `fore skill install` into a sandbox path; confirms packaged assets are
    # present in the PyInstaller bundle.
    system bin/"fore", "skill", "install", "claude",
           "-p", testpath/"claude/skills/forecli",
           "--no-hook"
    assert_predicate testpath/"claude/skills/forecli/SKILL.md", :exist?
  end
end
