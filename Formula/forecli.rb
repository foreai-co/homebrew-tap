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
  version "0.4.0"

  # BEGIN binaries — managed by scripts/update-brew-formula.py
  on_macos do
    url "https://github.com/foreai-co/homebrew-tap/releases/download/v0.4.0/forecli-0.4.0-darwin-arm64.tar.gz"
    sha256 "cae870780808f1b02b7a0574c02505c64ba875dd4fa91b47de915e8fead50bad"
  end
  on_linux do
    on_intel do
      url "https://github.com/foreai-co/homebrew-tap/releases/download/v0.4.0/forecli-0.4.0-linux-x86_64.tar.gz"
      sha256 "7626120449256f0713b5efcfa256f5394efd61c554d4129f4a98bc82f42d9791"
    end
    on_arm do
      url "https://github.com/foreai-co/homebrew-tap/releases/download/v0.4.0/forecli-0.4.0-linux-arm64.tar.gz"
      sha256 "0ad30eafb012a6c5dbe49227c515ce28b6394470c78ee6b641a3d92b542d60c7"
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

    Please note that most of the methods are build dynamically, so relying on method-names
    can be brittle and should be avoided.
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
