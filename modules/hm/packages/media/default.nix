# ═══════════════════════════════════════════════════════════════
# 🎵 MEDIA - AGGREGATOR
# ═══════════════════════════════════════════════════════════════
# ──── Delete a file to disable that media package ────────────
{lib, ...}: {
  imports =
    lib.optional (builtins.pathExists ./mpv.nix) ./mpv.nix
    ++ lib.optional (builtins.pathExists ./obs.nix) ./obs.nix
    ++ lib.optional (builtins.pathExists ./rnnoise.nix) ./rnnoise.nix;
}
