# ═══════════════════════════════════════════════════════════════
# 🌅 GAMMASTEP - BLUE LIGHT FILTER FOR WAYLAND
# ═══════════════════════════════════════════════════════════════
# ──── Wayland-only build, no X11/appindicator overhead ───────
# ──── Coordinates: San Salvador, El Salvador ─────────────────
{
  config,
  pkgs,
  ...
}: let
  configFile = "gammastep/config.ini";
  toINI = (pkgs.formats.ini {}).generate;

  gammastepWayland = pkgs.gammastep.override {
    withRandr = false;
    withDrm = false;
    withVidmode = false;
    withAppIndicator = false;
  };
in {
  home.packages = [gammastepWayland];

  systemd.user.services.gammastep = {
    Unit = {
      Description = "Gammastep colour temperature adjuster";
      Documentation = ["https://gitlab.com/chinstrap/gammastep/"];
      After = ["graphical-session.target"];
      PartOf = ["graphical-session.target"];
    };

    Install.WantedBy = ["graphical-session.target"];

    Service = {
      ExecStart = "${gammastepWayland}/bin/gammastep -c ${config.xdg.configHome}/${configFile}";
      Restart = "on-failure";
      RestartSec = "3";
    };
  };

  xdg.configFile."${configFile}".source = toINI "config.ini" {
    manual = {
      lat = "13.69";
      lon = "-89.19";
    };

    general = {
      brightness-day = "1.0";
      brightness-night = "0.5";
      adjustment-method = "wayland";
      location-provider = "manual";
      temp-day = "5500";
      temp-night = "3500";
    };
  };
}
