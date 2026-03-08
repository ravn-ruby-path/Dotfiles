# ═══════════════════════════════════════════════════════════════
# ✏️  EDITORS - EDITOR MODULE AGGREGATOR
# ═══════════════════════════════════════════════════════════════
# ──── Optional modules: delete the file to remove all config ──
{lib, ...}: {
  imports =
    lib.optional (builtins.pathExists ./helix/default.nix) ./helix/default.nix
    ++ lib.optional (builtins.pathExists ./zed/default.nix) ./zed/default.nix;
}
