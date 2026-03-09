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
    ./packages/apps/default.nix
    ./packages/browsers/default.nix
    ./packages/media/default.nix
    ./editors/default.nix
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

  # ═══════════════════════════════════════════════════════════════
  # 🗂️  VSCODE WORKSPACE — Always present after rebuild
  # ═══════════════════════════════════════════════════════════════
  # ──── Why: .vscode/ and statix.toml must live at            ───
  # ──── ~/Work/Dotfiles/ (workspace root) for VS Code to pick ───
  # ──── up formatOnSave, nil LSP, statix task and extension   ───
  # ──── recommendations. home.file ensures they survive        ───
  # ──── worktree changes and are recreated on every rebuild.  ───
  home.file = {
    "Work/Dotfiles/.vscode/settings.json".source = ../../.vscode/settings.json;
    "Work/Dotfiles/.vscode/extensions.json".source = ../../.vscode/extensions.json;
    "Work/Dotfiles/.vscode/tasks.json".source = ../../.vscode/tasks.json;
    # ──── statix.toml: read by VS Code "statix: check" task ───
    # ──── which runs from workspace root — without this file ───
    # ──── statix uses defaults and shows false-positive W04/W20 ─
    "Work/Dotfiles/statix.toml".source = ../../statix.toml;
  };

  # ──── HyDE Home Manager Integration ────────────────────────
  hydenix.hm.enable = true;
  # Visit https://github.com/richen604/hydenix/blob/main/docs/options.md for more options
}
