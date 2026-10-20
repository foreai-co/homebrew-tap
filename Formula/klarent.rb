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
  version "0.7.0"

  # BEGIN binaries — managed by scripts/update-brew-formula.py
  on_macos do
    url "https://github.com/foreai-co/homebrew-tap/releases/download/v0.7.0/klarent-0.7.0-darwin-arm64.tar.gz"
    sha256 "c737016d819093d2b14ab6001aece07107b1248b2505080041a1c88aa98da565"
  end
  on_linux do
    on_intel do
      url "https://github.com/foreai-co/homebrew-tap/releases/download/v0.7.0/klarent-0.7.0-linux-x86_64.tar.gz"
      sha256 "619e73654f02d7027545b7342b63e4d6a38b2ea4ef12f972f94e12d645cbebfb"
    end
    on_arm do
      url "https://github.com/foreai-co/homebrew-tap/releases/download/v0.7.0/klarent-0.7.0-linux-arm64.tar.gz"
      sha256 "3c7f25b704844bb7b62ef8cc3f10c6dc437c078d2a285ae3f083556440f318ab"
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
