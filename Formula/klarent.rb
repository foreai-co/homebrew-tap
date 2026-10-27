# Homebrew formula for klarent (the `klarent` CLI).
#
# Lives in this repo for review convenience; the canonical copy belongs in a
# tap repo (e.g. https://github.com/foreai-co/homebrew-tap). On every release
# the release workflow rewrites version + per-arch url/sha256 via
# scripts/update-brew-formula.py.
#
# We ship a PyInstaller-built standalone binary per (os, arch), so installs
# don't depend on the user's Python, libexpat, or any transitive Python build
# backend. Windows users download `klarent-<version>-windows-x86_64.exe`
# directly from the tap's GitHub release page (brew doesn't run on Windows).
#
# Install path (for end users):
#   brew tap foreai-co/tap
#   brew install klarent
#   klarent skill install      # interactive: copies SKILL.md + (opt-in) guardrails hook
class Klarent < Formula
  desc "CLI for the klarent platform"
  homepage "https://github.com/foreai-co/klarent"
  license "Apache-2.0"
  version "0.8.0"

  # BEGIN binaries — managed by scripts/update-brew-formula.py
  on_macos do
    url "https://github.com/foreai-co/homebrew-tap/releases/download/v0.8.0/klarent-0.8.0-darwin-arm64.tar.gz"
    sha256 "3518c5b9f7dea2b5bcdf382cbf2867905093da724d86d5a77dfaaa178a412841"
  end
  on_linux do
    on_intel do
      url "https://github.com/foreai-co/homebrew-tap/releases/download/v0.8.0/klarent-0.8.0-linux-x86_64.tar.gz"
      sha256 "b6f4b1f394a85d13bbef41c5e18c1ee5e58d2c2bddd7bb19893324228c9b9bc5"
    end
    on_arm do
      url "https://github.com/foreai-co/homebrew-tap/releases/download/v0.8.0/klarent-0.8.0-linux-arm64.tar.gz"
      sha256 "f0026f136c2825a67370f91d43abed3db71cdc768f0ddb585e7c5353d6a407f0"
    end
  end

  # END binaries

  def install
    # PyInstaller --onedir tarballs ship the binary alongside an `_internal/`
    # tree of bundled deps. Park the whole thing under libexec and symlink
    # the launcher into bin so brew picks it up on PATH. The binary resolves
    # `_internal/` relative to its real (libexec) path, so the symlink works.
    libexec.install Dir["*"]
    bin.install_symlink libexec/"klarent"
  end

  def caveats
    <<~EOS
    `klarent` is installed. Please do not hesitate to provide feedback. Safe travels.

    Please note that most of the methods are build dynamically, so relying on method-names
    can be brittle and should be avoided.
    EOS
  end

  test do
    # `klarent --help` exits non-zero in `no_args_is_help` mode, so call it
    # explicitly. The output must include the project description.
    assert_match "CLI for the klarent", shell_output("#{bin}/klarent --help")
    # `klarent skill install` into a sandbox path; confirms packaged assets are
    # present in the PyInstaller bundle.
    system bin/"klarent", "skill", "install", "claude",
           "-p", testpath/"claude/skills/klarent",
           "--no-hook"
    assert_predicate testpath/"claude/skills/klarent/SKILL.md", :exist?
  end
end
