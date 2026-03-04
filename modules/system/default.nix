# ═══════════════════════════════════════════════════════════════
# 🔧 SYSTEM MODULE - CUSTOM SYSTEM-LEVEL CONFIGURATION
# ═══════════════════════════════════════════════════════════════
{...}: {
  imports = [
    # ./example.nix - add your system modules here
  ];

  # === System Packages ===
  environment.systemPackages = [
    # pkgs.vscode - hydenix's vscode version
    # pkgs.userPkgs.vscode - your personal nixpkgs version
  ];
}
