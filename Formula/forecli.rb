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
  version "0.1.10"

  # BEGIN binaries — managed by scripts/update-brew-formula.py
  on_macos do
    url "https://github.com/foreai-co/homebrew-tap/releases/download/v0.1.10/forecli-0.1.10-darwin-arm64.tar.gz"
    sha256 "d110a006a358abc1968c5cda53e33015250f82da07e9ab7d89e79a6fc58bfc60"
  end
  on_linux do
    on_intel do
      url "https://github.com/foreai-co/homebrew-tap/releases/download/v0.1.10/forecli-0.1.10-linux-x86_64.tar.gz"
      sha256 "b8996c84da1a964fe8650abc27452cd14fa5279b9b3838e1a19ea6c80ae9ff1c"
    end
    on_arm do
      url "https://github.com/foreai-co/homebrew-tap/releases/download/v0.1.10/forecli-0.1.10-linux-arm64.tar.gz"
      sha256 "6aec236fb7ac42ca1f855251eca79ad48cbbe938b388a8a9bf440e3c7635c412"
    end
  end

  # END binaries

  def install
    # PyInstaller --onedir tarballs ship the binary alongside an `_internal/`
    # tree of bundled deps. Park the whole thing under libexec and symlink
    # the launcher into bin so brew picks it up on PATH. The binary resolves
    # `_internal/` relative to its real (libexec) path, so the symlink works.
    libexec.install Dir["*"]
    bin.install_symlink libexec/"fore"
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
