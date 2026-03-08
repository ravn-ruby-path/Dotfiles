# ═══════════════════════════════════════════════════════════════
# ⚙️  BROWSERS - AGGREGATOR
# ═══════════════════════════════════════════════════════════════
# ──── Delete a file to disable that browser ──────────────────
{lib, ...}: {
  imports =
    lib.optional (builtins.pathExists ./chromium.nix) ./chromium.nix
    ++ lib.optional (builtins.pathExists ./edge.nix) ./edge.nix;
}
