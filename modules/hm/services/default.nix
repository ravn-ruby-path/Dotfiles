# ═══════════════════════════════════════════════════════════════
# 🔧 SERVICES - USER SERVICES MODULE AGGREGATOR
# ═══════════════════════════════════════════════════════════════
{ lib, ... }: {
  imports =
    # ──── Optional modules: delete the file to remove all config ─
    (lib.optional (builtins.pathExists ./system/dropbox.nix) ./system/dropbox.nix);
}
