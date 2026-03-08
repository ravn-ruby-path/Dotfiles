# ═══════════════════════════════════════════════════════════════
# 🏠 HOME MANAGER - USER ENVIRONMENT ENTRY POINT
# ═══════════════════════════════════════════════════════════════
{
  config,
  lib,
  ...
}: {
  imports = [
    ./terminal/default.nix
    ./services/default.nix
  ];

  # === User Packages ===
  home.packages = [
    # pkgs.vscode - hydenix's vscode version
    # pkgs.userPkgs.vscode - your personal nixpkgs version
  ];

  # ═══════════════════════════════════════════════════════════════
  # 🛣️  SESSION PATH - Ensure full PATH for non-login shells
  # ═══════════════════════════════════════════════════════════════
  # ──── Why: VS Code and other GUI tools open non-login shells ──
  # ──── that skip /etc/profile, so HM user profile and local ───
  # ──── bins are missing from PATH. sessionPath injects them ───
  # ──── into hm-session-vars.sh, sourced by .zshenv for every ──
  # ──── shell instance (login, non-login, interactive or not). ─
  home.sessionPath = [
    "/etc/profiles/per-user/${config.home.username}/bin"
    "${config.home.homeDirectory}/.local/bin"
  ];

  # ──── HyDE Home Manager Integration ────────────────────────
  hydenix.hm.enable = true;
  # Visit https://github.com/richen604/hydenix/blob/main/docs/options.md for more options
}
