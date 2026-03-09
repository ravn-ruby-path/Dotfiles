# ═══════════════════════════════════════════════════════════════
# 🦶 FOOT - LIGHTWEIGHT WAYLAND TERMINAL
# ═══════════════════════════════════════════════════════════════
# ──── libsixel: enables inline image rendering in terminal ───
{
  config,
  lib,
  pkgs,
  ...
}: let
  configFile = "foot/foot.ini";
  toINI = (pkgs.formats.ini {}).generate;
in {
  home.packages = with pkgs; [foot libsixel];

  xdg.configFile."${configFile}".source = toINI "foot.ini" {
    main = {
      font = "GT Pressura Mono Trial:size=8.5:fontfeatures=calt:fontfeatures=dlig:fontfeatures=fbarc:fontfeatures=liga,PragmataProMonoLiga Nerd Font:size=8.5";
      horizontal-letter-offset = 0;
      vertical-letter-offset = 0;
      pad = "15x6center";
      term = "xterm-256color";
      selection-target = "both";
      include = "${config.xdg.configHome}/foot/themes/noctalia";
    };
    bell = {
      command = "notify-send bell";
      command-focused = "no";
      notify = "yes";
      urgent = "yes";
    };
    desktop-notifications.command = "${lib.getExe pkgs.libnotify} -a \${app-id} -i \${app-id} \${title} \${body}";
    scrollback = {
      lines = 1000;
      multiplier = 3;
      indicator-position = "relative";
      indicator-format = "line";
    };
    url = {
      launch = "${pkgs.xdg-utils}/bin/xdg-open \${url}";
      label-letters = "sadfjklewcmpgh";
      osc8-underline = "url-mode";
    };
    cursor = {
      style = "beam";
      beam-thickness = "2";
    };
    tweak = {
      font-monospace-warn = "no";
      sixel = "yes";
    };
    colors = {
      alpha = 1.0;
    };
  };
}
