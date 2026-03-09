# ═══════════════════════════════════════════════════════════════
# 🎬 MPV - MEDIA PLAYER WITH VA-API GPU ACCELERATION
# ═══════════════════════════════════════════════════════════════
# ──── mpris: lets media keys and status bars control mpv ─────
{
  pkgs,
  lib,
  ...
}: let
  configFile = "mpv/mpv.conf";
in {
  home.packages = with pkgs; [
    mpv
    mpvScripts.mpris
  ];

  xdg.configFile."${configFile}".text =
    lib.generators.toKeyValue {
      mkKeyValue = k: v: "${k}=${v}";
      listsAsDuplicateKeys = true;
    } {
      profile = "gpu-hq";
      osc = "no";
      "osd-bar" = "no";
      volume = "100";
      "volume-max" = "200";
      hwdec = "vaapi";
      "vo" = "gpu";
      "gpu-api" = "vulkan";
    };
}
