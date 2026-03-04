# ═══════════════════════════════════════════════════════════════
# 🔀 GIT - VERSION CONTROL WITH DELTA, GPG SIGNING AND LFS
# ═══════════════════════════════════════════════════════════════
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.terminal.software.git;
  toINI = (pkgs.formats.ini {}).generate;
  configFile = "git/config";
  ignoreFile = "git/ignore";
in {
  # ──── Options ────────────────────────────────────────────────────
  options.modules.terminal.software.git = {
    enable = lib.mkEnableOption "Git with advanced configuration";

    # === User Identity ===
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

    # === Editor and Tools ===
    editor = lib.mkOption {
      type = lib.types.str;
      default = "nvim";
      description = "Editor for commits and rebases";
      example = "code --wait";
    };

    # === Delta: Enhanced Diff Pager ===
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

    # === GPG Signing ===
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

    # === Git LFS ===
    lfs.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Git LFS for large files";
    };

    # === Custom Aliases ===
    extraAliases = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      description = "Additional git aliases";
      example = {wip = "commit -am 'WIP'";};
    };

    # === Global Gitignore ===
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

  # ──── Configuration ─────────────────────────────────────────────────
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      # ──── Packages ────────────────────────────────────────────
      home.packages = with pkgs;
        [
          git
          peco
        ]
        ++ lib.optionals cfg.delta.enable [delta]
        ++ lib.optionals cfg.gpg.enable [gnupg]
        ++ lib.optionals cfg.lfs.enable [git-lfs];

      # ──── Git Config File ───────────────────────────────────────
      xdg.configFile."${configFile}".source = toINI "config" (
        {
          # ──── Aliases ─────────────────────────────────────────────────
          alias =
            {
              # Basics
              st = "status";
              br = "branch";
              co = "checkout";
              d = "diff";

              # Commits
              ca = "commit -am";
              fuck = "commit --amend -m";

              # Push/Pull shortcuts
              pl = "!git pull origin $(git rev-parse --abbrev-ref HEAD)";
              ps = "!git push origin $(git rev-parse --abbrev-ref HEAD)";

              # Visual history
              hist = ''log --pretty=format:"%Cgreen%h %Creset%cd %Cblue[%cn] %Creset%s%C(yellow)%d%C(reset)" --graph --date=relative --decorate --all'';
              llog = ''log --graph --name-status --pretty=format:"%C(red)%h %C(reset)(%cd) %C(green)%an %Creset%s %C(yellow)%d%Creset" --date=relative'';

              # Interactive (requires fzf/peco)
              af = "!git add $(git ls-files -m -o --exclude-standard | fzf -m)";
              df = "!git hist | peco | awk '{print $2}' | xargs -I {} git diff {}^ {}";
            }
            // cfg.extraAliases;

          # ──── Core Settings ─────────────────────────────────────────────
          core =
            {
              editor = cfg.editor;
              whitespace = "fix,-indent-with-non-tab,trailing-space,cr-at-eol";
            }
            // lib.optionalAttrs cfg.delta.enable {
              pager = "${pkgs.delta}/bin/delta";
            };

          # ──── Branch and Merge ─────────────────────────────────────────
          init = {
            defaultBranch = "main";
          };

          pull = {
            ff = "only";
          };

          push = {
            autoSetupRemote = "true";
            default = "current";
          };

          # ──── URL Rewriting: HTTPS → SSH ──────────────────────────────
          "url \"git@github.com:\"" = {
            insteadOf = "https://github.com/";
          };

          merge = {
            conflictstyle = "diff3";
            stat = "true";
          };

          rebase = {
            autoSquash = "true";
            autoStash = "true";
          };

          diff = {
            colorMoved = "default";
          };

          rerere = {
            enabled = "true";
            autoupdate = "true";
          };

          # ──── User Identity ─────────────────────────────────────────────
          user =
            lib.optionalAttrs (cfg.userName != "") {
              name = cfg.userName;
            }
            // lib.optionalAttrs (cfg.userEmail != "") {
              email = cfg.userEmail;
            }
            // lib.optionalAttrs (cfg.gpg.enable && cfg.gpg.signingKey != "") {
              signingKey = cfg.gpg.signingKey;
            };
        }
        # ──── Delta: Enhanced Diff Pager ────────────────────────────────
        // lib.optionalAttrs cfg.delta.enable {
          delta = {
            features = "unobtrusive-line-numbers decorations";
            navigate = "true";
            "side-by-side" =
              if cfg.delta.sideBySide
              then "true"
              else "false";
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
        # ──── GPG Commit Signing ───────────────────────────────────────
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
        # ──── Git LFS ─────────────────────────────────────────────────
        // lib.optionalAttrs cfg.lfs.enable {
          "filter-lfs" = {
            clean = "git-lfs clean -- %f";
            process = "git-lfs filter-process";
            required = "true";
            smudge = "git-lfs smudge -- %f";
          };
        }
      );

      # ──── Global Gitignore ───────────────────────────────────────────
      xdg.configFile."${ignoreFile}".text =
        lib.concatStringsSep "\n" cfg.ignorePatterns;
    })

    # === Personal Settings ===
    {
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
