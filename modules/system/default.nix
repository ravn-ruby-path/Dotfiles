# ═══════════════════════════════════════════════════════════════
# 🔧 SYSTEM MODULE - CUSTOM SYSTEM-LEVEL CONFIGURATION
# ═══════════════════════════════════════════════════════════════
{...}: {
  imports = [];

  # === System Packages ===
  environment.systemPackages = [
    # pkgs.vscode - hydenix's vscode version
    # pkgs.userPkgs.vscode - your personal nixpkgs version
  ];

  # ═══════════════════════════════════════════════════════════════
  # 💾 FUSE - USERSPACE FILESYSTEM SUPPORT
  # ═══════════════════════════════════════════════════════════════
  # ──── Required for rclone to mount Google Drive as FUSE ──────
  # ──── Provides setuid fusermount3 at /run/wrappers/bin/ ──────
  programs.fuse.enable = true;
}
