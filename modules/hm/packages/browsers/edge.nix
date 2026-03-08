# ═══════════════════════════════════════════════════════════════
# ⚙️  MICROSOFT EDGE - WITH WAYLAND + GPU FLAGS
# ═══════════════════════════════════════════════════════════════
# ──── Unfree package: requires pkgsUnfree instantiation ──────
{
  pkgs,
  inputs,
  ...
}: let
  pkgsUnfree = import inputs.nixpkgs {
    inherit (pkgs) system;
    config.allowUnfree = true;
  };

  edgeWrapped = pkgs.symlinkJoin {
    name = "microsoft-edge-wrapped";
    paths = [pkgsUnfree.microsoft-edge];
    buildInputs = [pkgs.makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/microsoft-edge \
        --add-flags "--ignore-gpu-blocklist" \
        --add-flags "--enable-zero-copy" \
        --add-flags "--ozone-platform-hint=auto" \
        --add-flags "--ozone-platform=wayland" \
        --add-flags "--enable-wayland-ime" \
        --add-flags "--process-per-site" \
        --add-flags "--enable-features=WebUIDarkMode,UseOzonePlatform,VaapiVideoDecodeLinuxGL,VaapiVideoDecoder,WebRTCPipeWireCapturer,WaylandWindowDecorations"
    '';
  };
in {
  home.packages = [edgeWrapped];
}
