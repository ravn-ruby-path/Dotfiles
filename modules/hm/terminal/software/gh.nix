# GitHub CLI with environment-based config and shell aliases
#
# Documentation: docs/src/content/docs/github-cli.mdx
# Used by:    modules/hm/programs/terminal/software/default.nix
# Depends on: none
# ----------------------------------------------------------------------------
{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Customizable configuration
  cfg = config.modules.terminal.software.gh;
in
{
  # Configurable module options
  options.modules.terminal.software.gh = {
    enable = lib.mkEnableOption "GitHub CLI (gh)";
    
    # Editor for opening files (e.g. when editing PRs)
    editor = lib.mkOption {
      type = lib.types.str;
      default = "nano"; # Safe default
      description = "Default editor for gh";
      example = "nvim";
    };
    
    # Browser for opening links
    browser = lib.mkOption {
      type = lib.types.str;
      default = ""; # Use system default
      description = "Browser for opening GitHub links";
      example = "firefox";
    };
    
    # GitHub username
    username = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Your GitHub username";
      example = "linuxmobile";
    };
    
    # Git protocol (https or ssh)
    gitProtocol = lib.mkOption {
      type = lib.types.enum [ "https" "ssh" ];
      default = "https";
      description = "Protocol for Git operations";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
    # Install the gh package
    home.packages = with pkgs; [
      gh
    ];

    # Environment variables for gh configuration
    # (instead of config.yml which blocks authentication)
    home.sessionVariables = {
      GH_EDITOR = cfg.editor;
      GH_PAGER = "less -FR";
    } // lib.optionalAttrs (cfg.browser != "") {
      GH_BROWSER = cfg.browser;
    };

    # Useful aliases for gh (works in all shells: fish, zsh, bash)
    home.shellAliases = {
      ghco = "gh pr checkout";     # ghco <pr-number> - checkout a PR
      ghpv = "gh pr view";         # ghpv - view current PR
      ghrv = "gh repo view";       # ghrv - view current repo
      ghis = "gh issue status";    # ghis - issue status
    };
    })
    {
      # ----------------------------------------------------------------------------
      # Personal Settings
      # ----------------------------------------------------------------------------
      modules.terminal.software.gh = {
        enable = true;
        editor = "nano";
        username = "25asab015";
        gitProtocol = "https";
      };
    }
  ];
}
