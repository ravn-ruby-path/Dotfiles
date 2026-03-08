# ═══════════════════════════════════════════════════════════════
# 🔧 SYSTEM MODULE - CUSTOM SYSTEM-LEVEL CONFIGURATION
# ═══════════════════════════════════════════════════════════════
{lib, ...}: {
  imports = [];

  # ──── allowUnfree: gated on HM service modules that need it ──
  # ──── Dropbox (unfree) lives at hm/services/system/dropbox.nix
  nixpkgs.config.allowUnfree =
    builtins.pathExists ../hm/services/system/dropbox.nix;

  # === System Packages ===
  environment.systemPackages = [
    # pkgs.vscode - hydenix's vscode version
    # pkgs.userPkgs.vscode - your personal nixpkgs version
  ];
}
