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
  version "0.5.1"

  # BEGIN binaries — managed by scripts/update-brew-formula.py
  on_macos do
    url "https://github.com/foreai-co/homebrew-tap/releases/download/v0.5.1/klarent-0.5.1-darwin-arm64.tar.gz"
    sha256 "c3a1dac29d4b0670ef1c1c652b833a53e8dec2653098d6d64f0391f408210855"
  end
  on_linux do
    on_intel do
      url "https://github.com/foreai-co/homebrew-tap/releases/download/v0.5.1/klarent-0.5.1-linux-x86_64.tar.gz"
      sha256 "c0ba467111e341daafb4e23b7b217a2e3fff2183d62e8c0beb2befc505a0f7dc"
    end
    on_arm do
      url "https://github.com/foreai-co/homebrew-tap/releases/download/v0.5.1/klarent-0.5.1-linux-arm64.tar.gz"
      sha256 "ae327d5dd99c9698fd4245abd7f9e16bceb4b19eea9aa200cd983d2f5b8a6481"
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
