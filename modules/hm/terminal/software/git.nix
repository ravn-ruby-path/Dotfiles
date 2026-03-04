# Git version control with delta pager, GPG signing, and LFS
#
# Documentation: docs/src/content/docs/git.mdx
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
  cfg = config.modules.terminal.software.git;
  toINI = (pkgs.formats.ini {}).generate;
  configFile = "git/config";
  ignoreFile = "git/ignore";
in
{
  options.modules.terminal.software.git = {
    enable = lib.mkEnableOption "Git with advanced configuration";

    # ----------------------------------------------------------------------------
    # User identity
    # ----------------------------------------------------------------------------
    userName = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Your name for commits (e.g. 'John Doe')";
      example = "John Doe";
    };

    userEmail = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Your email for commits";
      example = "juan@example.com";
    };

    # ----------------------------------------------------------------------------
    # Editor and tools
    # ----------------------------------------------------------------------------
    editor = lib.mkOption {
      type = lib.types.str;
      default = "nvim";
      description = "Editor for commits and rebases";
      example = "code --wait";
    };

    # ----------------------------------------------------------------------------
    # Delta (enhanced pager with syntax highlighting)
    # ----------------------------------------------------------------------------
    delta = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Use delta as pager (pretty diffs)";
      };

      sideBySide = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Show side-by-side diffs";
      };
    };

    # ----------------------------------------------------------------------------
    # GPG signing (optional)
    # ----------------------------------------------------------------------------
    gpg = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Sign commits with GPG";
      };

      signingKey = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "GPG key ID for signing";
        example = "ABCD1234EFGH5678";
      };
    };

    # ----------------------------------------------------------------------------
    # Git LFS (large files)
    # ----------------------------------------------------------------------------
    lfs.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Git LFS for large files";
    };

    # ----------------------------------------------------------------------------
    # Custom aliases
    # ----------------------------------------------------------------------------
    extraAliases = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      description = "Additional git aliases";
      example = { wip = "commit -am 'WIP'"; };
    };

    # ----------------------------------------------------------------------------
    # Gitignore global
    # ----------------------------------------------------------------------------
    ignorePatterns = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "*~"
        "*.swp"
        "*result*"
        ".direnv"
        "node_modules"
        ".DS_Store"
        "*.log"
      ];
      description = "Patterns to ignore globally";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
    # Required packages
    home.packages = with pkgs; [
      git
      peco        # For interactive aliases
    ] 
    ++ lib.optionals cfg.delta.enable [ delta ]
    ++ lib.optionals cfg.gpg.enable [ gnupg ]
    ++ lib.optionals cfg.lfs.enable [ git-lfs ];

    # Main Git configuration
    xdg.configFile."${configFile}".source = toINI "config" (
      {
        # ----------------------------------------------------------------------------
        # Useful aliases
        # ----------------------------------------------------------------------------
        alias = {
          # Basics
          st = "status";
          br = "branch";
          co = "checkout";
          d = "diff";
          
          # Commits
          ca = "commit -am";
          fuck = "commit --amend -m";  # Change last commit message
          
          # Simplified Push/Pull
          pl = "!git pull origin $(git rev-parse --abbrev-ref HEAD)";
          ps = "!git push origin $(git rev-parse --abbrev-ref HEAD)";
          
          # Visual history
          hist = ''log --pretty=format:"%Cgreen%h %Creset%cd %Cblue[%cn] %Creset%s%C(yellow)%d%C(reset)" --graph --date=relative --decorate --all'';
          llog = ''log --graph --name-status --pretty=format:"%C(red)%h %C(reset)(%cd) %C(green)%an %Creset%s %C(yellow)%d%Creset" --date=relative'';
          
          # Interactive (requires fzf/peco)
          af = "!git add $(git ls-files -m -o --exclude-standard | fzf -m)";
          df = "!git hist | peco | awk '{print $2}' | xargs -I {} git diff {}^ {}";
        } // cfg.extraAliases;

        # ----------------------------------------------------------------------------
        # Core
        # ----------------------------------------------------------------------------
        core = {
          editor = cfg.editor;
          whitespace = "fix,-indent-with-non-tab,trailing-space,cr-at-eol";
        } // lib.optionalAttrs cfg.delta.enable {
          pager = "${pkgs.delta}/bin/delta";
        };

        # ----------------------------------------------------------------------------
        # Branch and merge configuration
        # ----------------------------------------------------------------------------
        init = {
          defaultBranch = "main";
        };

        pull = {
          ff = "only";  # Fast-forward only, avoid automatic merges
        };

        push = {
          autoSetupRemote = "true";
          default = "current";
        };

        # ----------------------------------------------------------------------------
        # URL rewriting: HTTPS → SSH (never ask for password again)
        # ----------------------------------------------------------------------------
        "url \"git@github.com:\"" = {
          insteadOf = "https://github.com/";
        };

        merge = {
          conflictstyle = "diff3";  # Show common ancestor in conflicts
          stat = "true";
        };

        rebase = {
          autoSquash = "true";
          autoStash = "true";  # Auto stash before rebase
        };

        diff = {
          colorMoved = "default";
        };

        rerere = {
          enabled = "true";      # Remember conflict resolutions
          autoupdate = "true";
        };

        # ----------------------------------------------------------------------------
        # User (if configured)
        # ----------------------------------------------------------------------------
        user = lib.optionalAttrs (cfg.userName != "") {
          name = cfg.userName;
        } // lib.optionalAttrs (cfg.userEmail != "") {
          email = cfg.userEmail;
        } // lib.optionalAttrs (cfg.gpg.enable && cfg.gpg.signingKey != "") {
          signingKey = cfg.gpg.signingKey;
        };
      }

      # ----------------------------------------------------------------------------
      # Delta (enhanced pager) - only if enabled
      # ----------------------------------------------------------------------------
      // lib.optionalAttrs cfg.delta.enable {
        delta = {
          features = "unobtrusive-line-numbers decorations";
          navigate = "true";
          "side-by-side" = if cfg.delta.sideBySide then "true" else "false";
          "true-color" = "never";
        };

        "delta-decorations" = {
          "commit-decoration-style" = "bold grey box ul";
          "file-decoration-style" = "ul";
          "file-style" = "bold blue";
          "hunk-header-decoration-style" = "box";
        };

        "delta-unobtrusive-line-numbers" = {
          "line-numbers" = "true";
          "line-numbers-left-format" = "{nm:>4}│";
          "line-numbers-left-style" = "grey";
          "line-numbers-right-format" = "{np:>4}│";
          "line-numbers-right-style" = "grey";
        };

        interactive = {
          diffFilter = "${pkgs.delta}/bin/delta --color-only";
        };
      }

      # ----------------------------------------------------------------------------
      # GPG - only if enabled
      # ----------------------------------------------------------------------------
      // lib.optionalAttrs cfg.gpg.enable {
        commit = {
          gpgSign = "true";
        };

        tag = {
          gpgSign = "true";
        };

        gpg = {
          format = "openpgp";
        };

        "gpg-openpgp" = {
          program = "${pkgs.gnupg}/bin/gpg";
        };
      }

      # ----------------------------------------------------------------------------
      # Git LFS - only if enabled
      # ----------------------------------------------------------------------------
      // lib.optionalAttrs cfg.lfs.enable {
        "filter-lfs" = {
          clean = "git-lfs clean -- %f";
          process = "git-lfs filter-process";
          required = "true";
          smudge = "git-lfs smudge -- %f";
        };
      }
    );

    # Global gitignore
    xdg.configFile."${ignoreFile}".text = 
      lib.concatStringsSep "\n" cfg.ignorePatterns;
    })
    {
      # ----------------------------------------------------------------------------
      # Personal Settings
      # ----------------------------------------------------------------------------
      modules.terminal.software.git = {
        enable = true;
        userName = "Roberto Flores";
        userEmail = "25asab015@ujmd.edu.sv";
        editor = "nvim";
        delta.enable = true;
        delta.sideBySide = true;
        lfs.enable = true;
        gpg.enable = true;
        gpg.signingKey = "DDA77282";
      };
    }
  ];
}
