# ═══════════════════════════════════════════════════════════════
# 📦 APPS - USER APPLICATION AGGREGATOR
# ═══════════════════════════════════════════════════════════════
# ──── Optional modules: delete the file to remove all config ──
{lib, ...}: {
  imports =
    lib.optional (builtins.pathExists ./antigravity.nix) ./antigravity.nix;
}
