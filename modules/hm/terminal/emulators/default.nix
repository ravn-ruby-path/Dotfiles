# ═══════════════════════════════════════════════════════════════
# 💻 TERMINAL EMULATORS - AGGREGATOR
# ═══════════════════════════════════════════════════════════════
# ──── Delete a file to disable that emulator ─────────────────
{lib, ...}: {
  imports =
    lib.optional (builtins.pathExists ./foot.nix) ./foot.nix
    ++ lib.optional (builtins.pathExists ./ghostty.nix) ./ghostty.nix;
}
