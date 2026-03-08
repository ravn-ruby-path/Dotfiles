# ═══════════════════════════════════════════════════════════════
# 📦 DROPBOX - CLOUD STORAGE WITH AUTOSTART
# ═══════════════════════════════════════════════════════════════
# ──── Self-contained: delete this file to remove all config ───
# ──── Why local pkgs: hydenix creates nixpkgs externally, so  ───
# ──── nixpkgs.config cannot be set in any NixOS module.       ───
# ──── We instantiate our own nixpkgs with allowUnfree here.   ───
{ pkgs, inputs, ... }:
let
  # ──── Local nixpkgs instance with unfree packages enabled ───
  pkgsUnfree = import inputs.nixpkgs {
    inherit (pkgs) system;
    config.allowUnfree = true;
  };
in
{
  # ──── Install Dropbox ─────────────────────────────────────
  home.packages = [ pkgsUnfree.dropbox ];

  # ──── Systemd User Service: Autostart on graphical login ──
  # ──── On first run: downloads and installs the Dropbox daemon
  # ──── start -i keeps the process in foreground for systemd ─
  systemd.user.services.dropbox = {
    Unit = {
      Description = "Dropbox";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgsUnfree.dropbox}/bin/dropbox start -i";
      ExecStop = "${pkgsUnfree.dropbox}/bin/dropbox stop";
      Restart = "on-failure";
      RestartSec = 1;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
