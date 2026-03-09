# ═══════════════════════════════════════════════════════════════
# 🎙️ RNNOISE - AI MICROPHONE NOISE CANCELLATION
# ═══════════════════════════════════════════════════════════════
# ──── PipeWire filter-chain: creates virtual denoised source ─
# ──── VAD threshold 70%: filters background noise/keyboard  ──
{pkgs, ...}: let
  configFile = "pipewire/pipewire.conf.d/99-input-denoising.conf";
in {
  home.packages = with pkgs; [
    rnnoise
    rnnoise-plugin
  ];

  xdg.configFile."${configFile}".text = builtins.toJSON {
    "context.modules" = [
      {
        "name" = "libpipewire-module-filter-chain";
        "args" = {
          "node.description" = "Noise Canceling source";
          "media.name" = "Noise Canceling source";
          "filter.graph" = {
            "nodes" = [
              {
                "type" = "ladspa";
                "name" = "rnnoise";
                "plugin" = "${pkgs.rnnoise-plugin}/lib/ladspa/librnnoise_ladspa.so";
                "label" = "noise_suppressor_stereo";
                "control" = {"VAD Threshold (%)" = 70.0;};
              }
            ];
          };
          "audio.position" = ["FL" "FR"];
          "capture.props" = {
            "node.name" = "effect_input.rnnoise";
            "node.passive" = true;
          };
          "playback.props" = {
            "node.name" = "effect_output.rnnoise";
            "media.class" = "Audio/Source";
          };
        };
      }
    ];
  };
}
