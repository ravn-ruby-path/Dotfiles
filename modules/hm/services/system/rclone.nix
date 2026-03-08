# ═══════════════════════════════════════════════════════════════
# ☁️  RCLONE - GOOGLE DRIVE FUSE MOUNT
# ═══════════════════════════════════════════════════════════════
# ──── Self-contained: delete this file to remove all config ───
# ──── First-time setup: run `gdrive-auth` once after rebuild  ─
# ──── The mount starts automatically on login after auth.    ───
#
# ──── Usage after rebuild:                                   ───
# ────   1. Run `gdrive-auth` in terminal                     ───
# ────   2. A browser opens — log in with your Google account ───
# ────   3. Done. Drive mounts at ~/GoogleDrive automatically  ───
# ════════════════════════════════════════════════════════════════
{
  pkgs,
  lib,
  config,
  ...
}: let
  # ──── Hardcoded config — adjust if needed ─────────────────
  remoteName = "gdrive";
  mountPoint = "${config.home.homeDirectory}/GoogleDrive";
  rcloneConf = "${config.xdg.configHome}/rclone/rclone.conf";
in {
  # ──── Install rclone ──────────────────────────────────────
  home.packages = [pkgs.rclone];

  # ──── Create mount point directory on every activation ────
  home.activation.createGdriveMountPoint = lib.hm.dag.entryAfter ["writeBoundary"] ''
    $DRY_RUN_CMD mkdir -p "${mountPoint}"
  '';

  # ──── Systemd user service: auto-mount on login ───────────
  # ──── Skips silently if rclone.conf doesn't exist yet ─────
  # ──── (i.e. before running gdrive-auth for the first time) ─
  systemd.user.services.rclone-gdrive = {
    Unit = {
      Description = "Google Drive FUSE mount via rclone";
      After = ["network-online.target"];
      Wants = ["network-online.target"];
      # ── Skip if auth hasn't been done yet ─────────────────
      ConditionPathExists = rcloneConf;
    };

    Service = {
      # ── notify: rclone signals systemd when mount is ready ─
      Type = "notify";

      ExecStart = lib.strings.concatStringsSep " " [
        "${pkgs.rclone}/bin/rclone mount"
        "${remoteName}:"
        mountPoint
        # ── Cache: keep recently used files locally ──────────
        "--vfs-cache-mode full"
        "--vfs-cache-max-size 2G"
        # ── Dir cache: avoid hammering the API ───────────────
        "--dir-cache-time 1000h"
        "--poll-interval 15s"
        # ── Permissions ──────────────────────────────────────
        "--umask 022"
        # ── Logging ──────────────────────────────────────────
        "--log-level INFO"
      ];

      # ── Unmount cleanly on service stop ───────────────────
      # ── NixOS provides setuid fusermount3 at this path ────
      ExecStop = "/run/wrappers/bin/fusermount3 -u ${mountPoint}";

      Restart = "on-failure";
      RestartSec = 5;
    };

    Install = {
      WantedBy = ["default.target"];
    };
  };

  # ──── One-time auth helper ────────────────────────────────
  # ──── Placed in PATH via home.sessionPath (.local/bin) ────
  home.file.".local/bin/gdrive-auth" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      REMOTE="${remoteName}"
      MOUNT="${mountPoint}"
      CONF="${rcloneConf}"

      echo "╭──────────────────────────────────────────────────────╮"
      echo "│  ☁️   Google Drive — First-time Setup                 │"
      echo "╰──────────────────────────────────────────────────────╯"
      echo ""

      # ── Check if already configured ───────────────────────
      if ${pkgs.rclone}/bin/rclone listremotes 2>/dev/null | grep -q "^''${REMOTE}:"; then
        echo "  Remote '$REMOTE' is already configured."
        echo "  Re-running will let you refresh the token."
        echo ""
        read -rp "  Continue? [y/N] " answer
        [[ "''${answer,,}" == "y" ]] || exit 0
        echo ""
      fi

      echo "  Steps:"
      echo "    1. The rclone config wizard will open"
      echo "    2. Choose: n (New remote)"
      echo "    3. Name:   ${remoteName}"
      echo "    4. Type:   drive  (Google Drive)"
      echo "    5. Leave client_id and client_secret blank (use defaults)"
      echo "    6. Scope:  1  (Full access)"
      echo "    7. Leave root_folder_id blank"
      echo "    8. Auto config: y  (opens browser)"
      echo "    9. Log in with your Google account in the browser"
      echo "   10. Team Drive: n  (unless you need it)"
      echo "   11. Confirm: y"
      echo "   12. Quit: q"
      echo ""
      read -rp "  Press Enter to start rclone config..."

      # ── Launch interactive rclone config ──────────────────
      ${pkgs.rclone}/bin/rclone config

      echo ""

      # ── Verify the remote was created ─────────────────────
      if ! ${pkgs.rclone}/bin/rclone listremotes 2>/dev/null | grep -q "^''${REMOTE}:"; then
        echo "  ✗ Remote '$REMOTE' was not found in config."
        echo "    Make sure you named it exactly: ${remoteName}"
        exit 1
      fi

      echo "  ✓ Remote '$REMOTE' configured successfully."
      echo ""

      # ── Enable and start the mount service ────────────────
      echo "  Starting the mount service..."
      systemctl --user daemon-reload
      systemctl --user enable rclone-gdrive
      systemctl --user start rclone-gdrive

      sleep 2

      if systemctl --user is-active --quiet rclone-gdrive; then
        echo "  ✓ Google Drive mounted at: $MOUNT"
      else
        echo "  ✗ Service failed to start. Check with:"
        echo "      journalctl --user -u rclone-gdrive -n 30"
        exit 1
      fi

      echo ""
      echo "╭──────────────────────────────────────────────────────╮"
      echo "│  ✓ Done! Google Drive is ready.                      │"
      echo "│                                                      │"
      echo "│  Mount: $MOUNT"
      echo "│                                                      │"
      echo "│  Useful commands:                                    │"
      echo "│    systemctl --user status rclone-gdrive             │"
      echo "│    systemctl --user stop   rclone-gdrive             │"
      echo "│    systemctl --user start  rclone-gdrive             │"
      echo "╰──────────────────────────────────────────────────────╯"
      echo ""
    '';
  };
}
