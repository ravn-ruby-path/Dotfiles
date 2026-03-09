# ═══════════════════════════════════════════════════════════════
# 🐟 FISH - INTERACTIVE SHELL CONFIGURATION
# ═══════════════════════════════════════════════════════════════
{pkgs, ...}: {
  home.packages = with pkgs; [
    fish
    grc
    zellij
    wl-clipboard
    (writeShellScriptBin "hx" ''
      ${pkgs.helix}/bin/hx "$@"
    '')
  ];

  xdg.configFile = {
    "fish/config.fish" = {
      text = ''
        set -gx NIXPKGS_ALLOW_UNFREE 1
        set -gx NIXPKGS_ALLOW_INSECURE 1
        set -gx EDITOR nvim
        set -gx VISUAL nvim
        set -gx ZELLIJ_AUTO_ATTACH false
        set -gx ZELLIJ_AUTO_EXIT true

        set -g fish_greeting

        # Vi keybindings
        fish_vi_key_bindings

        # Custom key bindings function (REQUIRED to properly unbind keys)
        function fish_user_key_bindings
          # Custom bindings
          for mode in insert default
            bind -M $mode ctrl-backspace backward-kill-word
            bind -M $mode ctrl-z undo
            bind -M $mode ctrl-b beginning-of-line
            bind -M $mode ctrl-e end-of-line
          end

          bind -M insert \cx\ce edit_command_buffer
          bind -M default \cx\ce edit_command_buffer

          # History search with prefix (like nushell)
          bind -M insert up history-prefix-search-backward
          bind -M insert down history-prefix-search-forward
          bind -M default up history-prefix-search-backward
          bind -M default down history-prefix-search-forward

          # UNBIND alt-s and alt-v completely (for Zellij)
          bind -M insert alt-s ""
          bind -M default alt-s ""
          bind -M insert alt-v ""
          bind -M default alt-v ""
          bind -M insert alt-z ""
          bind -M default alt-z ""
        end

        # Cursor shapes per mode
        set fish_cursor_default block
        set fish_cursor_insert line
        set fish_cursor_replace_one underscore
        set fish_cursor_visual block

        # Syntax colors
        set -g fish_color_autosuggestion brblack
        set -g fish_color_command blue
        set -g fish_color_error red
        set -g fish_color_param normal

        # Search highlight
        set -g fish_color_search_match --background=normal

        # Plugin settings
        set -Ux fifc_editor nvim
        set -U fifc_keybinding \cv
        set -g __done_min_cmd_duration 10000

        if status is-interactive; and test "$Z" != "0"
          eval (zellij setup --generate-auto-start fish | string collect)
        end
      '';
    };

    "fish/functions/fcd.fish" = {
      text = ''
        function fcd
          set -l dir (fd --type d | sk | string trim)
          if test -n "$dir"
            z $dir
          end
        end
      '';
    };

    "fish/functions/installed.fish" = {
      text = ''
        function installed
          nix-store --query --requisites /run/current-system/ | string replace -r '.*?-(.*)' '$1' | sort | uniq | sk
        end
      '';
    };

    "fish/functions/installedall.fish" = {
      text = ''
        function installedall
          nix-store --query --requisites /run/current-system/ | sk | wl-copy
        end
      '';
    };

    "fish/functions/fm.fish" = {
      text = ''
        function fm
          set -l tmp (mktemp -t "yazi-cwd.XXXXX")
          yazi $argv --cwd-file $tmp
          set -l cwd (cat $tmp)
          if test -n "$cwd" -a "$cwd" != "$PWD"
            cd $cwd
          end
          rm -f $tmp
        end
      '';
    };

    "fish/functions/gitgrep.fish" = {
      text = ''
        function gitgrep
          git ls-files | rg $argv
        end
      '';
    };

    "fish/conf.d/aliases.fish" = {
      text = ''
        alias cleanup="sudo nix-collect-garbage --delete-older-than 1d"
        alias listgen="sudo nix-env -p /nix/var/nix/profiles/system --list-generations"
        alias nixremove="nix-store --gc"
        alias bloat="nix path-info -Sh /run/current-system"
        alias cleanram="sudo sh -c 'sync; echo 3 > /proc/sys/vm/drop_caches'"
        alias trimall="sudo fstrim -va"
        alias c="clear"
        alias q="exit"
        alias temp="cd /tmp/"
        alias test-build="sudo nixos-rebuild test --flake .#hydenix"
        alias switch-build="sudo nixos-rebuild switch --flake .#hydenix"
        alias add="git add ."
        alias commit="git commit"
        alias push="git push"
        alias pull="git pull"
        alias diff="git diff --staged"
        alias gcld="git clone --depth 1"
        alias gitui="lazygit"
        alias ls="eza --icons"
        alias l="eza -lF --time-style=long-iso --icons"
        alias ll="eza -h --git --icons --color=auto --group-directories-first -s extension"
        alias tree="eza --tree --icons --tree"
        alias cat="${pkgs.bat}/bin/bat --paging=never"
        alias moon="${pkgs.curlMinimal}/bin/curl -s wttr.in/Moon"
        alias weather="${pkgs.curlMinimal}/bin/curl -s wttr.in"
        alias store-path="${pkgs.coreutils-full}/bin/readlink (${pkgs.which}/bin/which $argv)"
        alias us="systemctl --user"
        alias rs="sudo systemctl"
        alias zed="zeditor"
      '';
    };
  };
}
