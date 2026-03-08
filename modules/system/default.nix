# ═══════════════════════════════════════════════════════════════
# 🔧 SYSTEM MODULE - CUSTOM SYSTEM-LEVEL CONFIGURATION
# ═══════════════════════════════════════════════════════════════
{lib, ...}: {
  imports =
    # ──── Optional modules: delete the file to remove all config ─
    lib.optional (builtins.pathExists ./dropbox.nix) ./dropbox.nix;

  # === System Packages ===
  environment.systemPackages = [
    # pkgs.vscode - hydenix's vscode version
    # pkgs.userPkgs.vscode - your personal nixpkgs version
  ];
}
