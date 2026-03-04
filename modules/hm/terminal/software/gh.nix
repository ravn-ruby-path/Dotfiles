# ═══════════════════════════════════════════════════════════════
# 🐙 GITHUB CLI - ENVIRONMENT-BASED CONFIG AND SHELL ALIASES
# ═══════════════════════════════════════════════════════════════
{
  config,
  lib,
  pkgs,
  ...
}: let
  # Customizable configuration
  cfg = config.modules.terminal.software.gh;
in {
  # ──── Options ────────────────────────────────────────────────────
  options.modules.terminal.software.gh = {
    enable = lib.mkEnableOption "GitHub CLI (gh)";

    # === Editor ===
    editor = lib.mkOption {
      type = lib.types.str;
      default = "nano";
      description = "Default editor for gh";
      example = "nvim";
    };

    # === Browser ===
    browser = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Browser for opening GitHub links";
      example = "firefox";
    };

    # === Identity ===
    username = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Your GitHub username";
      example = "25ASAB015";
    };

    # === Git Protocol (https or ssh) ===
    gitProtocol = lib.mkOption {
      type = lib.types.enum ["https" "ssh"];
      default = "https";
      description = "Protocol for Git operations";
    };
  };

  # ──── Configuration ─────────────────────────────────────────────────
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      home = {
        # ──── Packages ──────────────────────────────────────────
        packages = with pkgs; [gh];

        # ──── Session Variables ─────────────────────────────────
        sessionVariables =
          {
            GH_EDITOR = cfg.editor;
            GH_PAGER = "less -FR";
          }
          // lib.optionalAttrs (cfg.browser != "") {
            GH_BROWSER = cfg.browser;
          };

        # ──── Shell Aliases ─────────────────────────────────────
        shellAliases = {
          ghco = "gh pr checkout";
          ghpv = "gh pr view";
          ghrv = "gh repo view";
          ghis = "gh issue status";
        };
      };
    })

    # === Personal Settings ===
    {
      modules.terminal.software.gh = {
        enable = true;
        editor = "nano";
        username = "25asab015";
        gitProtocol = "https";
      };
    }
  ];
}
