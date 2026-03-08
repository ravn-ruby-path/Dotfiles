# ═══════════════════════════════════════════════════════════════
# 📦 DROPBOX - CLOUD STORAGE WITH AUTOSTART
# ═══════════════════════════════════════════════════════════════
# ──── Self-contained: delete this file to remove all config ───
{ pkgs, ... }: {

  # ──── Allow Unfree: Dropbox is proprietary software ──────────
  nixpkgs.config.allowUnfree = true;

  # ──── User Environment: Package + Autostart ──────────────────
  home-manager.users.ravn = {

    # ──── Install Dropbox ───────────────────────────────────────
    home.packages = [ pkgs.dropbox ];

    # ──── Systemd User Service: Autostart on graphical login ────
    # ──── On first run: downloads and installs the Dropbox daemon
    # ──── start -i keeps the process in foreground for systemd ──
    systemd.user.services.dropbox = {
      Unit = {
        Description = "Dropbox";
        After       = [ "graphical-session.target" ];
        PartOf      = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart  = "${pkgs.dropbox}/bin/dropbox start -i";
        ExecStop   = "${pkgs.dropbox}/bin/dropbox stop";
        Restart    = "on-failure";
        RestartSec = 1;
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
