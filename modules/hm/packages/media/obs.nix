# ═══════════════════════════════════════════════════════════════
# 🎥 OBS STUDIO - WITH VA-API AND PIPEWIRE PLUGINS
# ═══════════════════════════════════════════════════════════════
# ──── Wayland native, PipeWire audio capture, VA-API encode ──
{pkgs, ...}: let
  obsBase = pkgs.obs-studio.override {
    pipewireSupport = true;
    browserSupport = true;
  };

  plugins = with pkgs.obs-studio-plugins; [
    obs-gstreamer
    obs-pipewire-audio-capture
    obs-vaapi
  ];

  obsPluginEnv = pkgs.buildEnv {
    name = "obs-studio-with-plugins-env";
    paths = plugins;
  };

  obsWrapped = pkgs.symlinkJoin {
    name = "obs-studio-wrapped";
    paths = [obsBase];
    buildInputs = [pkgs.makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/obs \
        --set OBS_PLUGINS_PATH "${obsPluginEnv}/lib/obs-plugins" \
        --set OBS_PLUGINS_DATA_PATH "${obsPluginEnv}/share/obs/obs-plugins" \
        --add-flags "--ozone-platform=wayland"
    '';
  };
in {
  home.packages = [obsWrapped];
}
