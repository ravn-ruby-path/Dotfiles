# ═══════════════════════════════════════════════════════════════
# 📋 CLIPHIST - WAYLAND CLIPBOARD MANAGER
# ═══════════════════════════════════════════════════════════════
# ──── Watches wl-paste and stores clipboard entries in a DB ──
{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    cliphist
    wl-clipboard
  ];

  systemd.user.services.cliphist = {
    Unit = {
      Description = "Clipboard management daemon";
      After = ["graphical-session.target"];
      PartOf = ["graphical-session.target"];
    };

    Install.WantedBy = ["graphical-session.target"];

    Service = {
      ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --watch ${pkgs.cliphist}/bin/cliphist -max-dedupe-search 10 -max-items 500 store";
      Restart = "on-failure";
      Type = "simple";
    };
  };

  xdg.configFile."cliphist/cliphistrc".text = ''
    allow_images=true
    max_entries=500
    database=${config.xdg.dataHome}/cliphist/db
  '';
}
