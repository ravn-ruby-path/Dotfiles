# ═══════════════════════════════════════════════════════════════
# 🦇 BAT - CAT WITH SYNTAX HIGHLIGHTING + MAN PAGER
# ═══════════════════════════════════════════════════════════════
{
  pkgs,
  lib,
  ...
}: let
  configFile = "bat/config";

  manPager = pkgs.writeShellScriptBin "manpager" ''
    ${pkgs.coreutils}/bin/col -bx | ${pkgs.bat}/bin/bat -l man -p "$@"
  '';
in {
  home.sessionVariables = {
    MANPAGER = "${manPager}/bin/manpager";
    MANROFFOPT = "-c";
  };

  home.packages = with pkgs; [
    bat
    manPager
  ];

  xdg.configFile."${configFile}".text =
    lib.generators.toKeyValue {
      mkKeyValue = k: v: "--${lib.escapeShellArg k}=${lib.escapeShellArg v}";
      listsAsDuplicateKeys = true;
    } {
      pager = "less -FR";
      style = "plain";
      theme = "base16";
    };
}
