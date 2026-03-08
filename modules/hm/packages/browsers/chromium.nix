# ═══════════════════════════════════════════════════════════════
# ⚙️  UNGOOGLED CHROMIUM - WITH WAYLAND + GPU FLAGS
# ═══════════════════════════════════════════════════════════════
{
  pkgs,
  lib,
  ...
}: let
  chromiumFlags = import ./_chromium-flags.nix;

  chromiumWrapped = pkgs.symlinkJoin {
    name = "ungoogled-chromium-wrapped";
    paths = [pkgs.ungoogled-chromium];
    buildInputs = [pkgs.makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/chromium \
        ${lib.concatMapStringsSep " \\\n        " (flag: "--add-flags \"${flag}\"") chromiumFlags.flags}
    '';
  };
in {
  home.packages = [chromiumWrapped];
  home.sessionVariables = chromiumFlags.sessionVariables;
}
