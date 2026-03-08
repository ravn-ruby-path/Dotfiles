# ═══════════════════════════════════════════════════════════════
# 🤖 ANTIGRAVITY - GOOGLE AGENTIC IDE
# ═══════════════════════════════════════════════════════════════
# ──── Self-contained: delete this file to remove all config ───
# ──── Why local pkgs: hydenix creates nixpkgs externally, so  ───
# ──── nixpkgs.config cannot be set in any NixOS module.       ───
# ──── We instantiate our own nixpkgs with allowUnfree here.   ───
# ──── antigravity-fhs: FHS-wrapped variant — allows installing ─
# ──── extensions without NixOS-specific patching.             ───
{
  pkgs,
  inputs,
  ...
}: let
  # ──── Local nixpkgs instance with unfree packages enabled ───
  pkgsUnfree = import inputs.nixpkgs {
    inherit (pkgs) system;
    config.allowUnfree = true;
  };
in {
  # ──── Install Antigravity (FHS wrapper for extension support) ─
  home.packages = [pkgsUnfree.antigravity-fhs];
}
