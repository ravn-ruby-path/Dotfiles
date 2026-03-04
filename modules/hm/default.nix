# ═══════════════════════════════════════════════════════════════
# 🏠 HOME MANAGER - USER ENVIRONMENT ENTRY POINT
# ═══════════════════════════════════════════════════════════════
{...}: {
  imports = [
    ./terminal/default.nix
  ];

  # === User Packages ===
  home.packages = [
    # pkgs.vscode - hydenix's vscode version
    # pkgs.userPkgs.vscode - your personal nixpkgs version
  ];

  # ──── HyDE Home Manager Integration ────────────────────────
  hydenix.hm.enable = true;
  # Visit https://github.com/richen604/hydenix/blob/main/docs/options.md for more options
}
