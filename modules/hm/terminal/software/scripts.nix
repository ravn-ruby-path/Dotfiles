# ═══════════════════════════════════════════════════════════════
# 📜 SCRIPTS - GIT WORKFLOW SCRIPTS INSTALLED TO ~/.local/bin
# ═══════════════════════════════════════════════════════════════
# Scripts source: scripts branch → bin/
#
# Installed scripts:
#   git-bare-clone       Clone a repo as bare + create all worktrees
#   git-create-worktree  Create a single worktree with upstream tracking
{
  config,
  lib,
  ...
}: let
  cfg = config.modules.terminal.software.scripts;
in {
  # ──── Options ────────────────────────────────────────────────────
  options.modules.terminal.software.scripts = {
    enable = lib.mkEnableOption "Git workflow scripts in ~/.local/bin";
  };

  # ──── Configuration ─────────────────────────────────────────────────
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      home.file = {
        # ──── git-bare-clone ────────────────────────────────────
        ".local/bin/git-bare-clone" = {
          source = ../../../../bin/git-bare-clone;
          executable = true;
        };

        # ──── git-create-worktree ────────────────────────────────
        ".local/bin/git-create-worktree" = {
          source = ../../../../bin/git-create-worktree;
          executable = true;
        };
      };
    })

    # === Personal Settings ===
    {
      modules.terminal.software.scripts.enable = true;
    }
  ];
}
