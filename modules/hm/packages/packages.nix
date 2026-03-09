# ═══════════════════════════════════════════════════════════════
# 📦 PACKAGES - GENERAL PURPOSE PACKAGES
# ═══════════════════════════════════════════════════════════════
{pkgs, ...}: {
  home.packages = with pkgs; [
    # === Messaging ===
    telegram-desktop

    # === Media ===
    ffmpegthumbnailer
    imagemagick

    # === GNOME Apps ===
    file-roller
    (papers.override {supportNautilus = true;})
    nautilus
    gnome-text-editor
    gnome-control-center

    # === System Tools ===
    pciutils
    openvpn

    # === Creative ===
    inkscape

    # === Android ===
    scrcpy
    android-tools
  ];
}
