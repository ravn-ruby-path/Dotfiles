# ═══════════════════════════════════════════════════════════════
# 🐚 SHELL - SHELL MODULE AGGREGATOR
# ═══════════════════════════════════════════════════════════════
{lib, ...}: {
  imports =
    (lib.optional (builtins.pathExists ./carapace.nix) ./carapace.nix)
    ++ (lib.optional (builtins.pathExists ./starship.nix) ./starship.nix)
    ++ (lib.optional (builtins.pathExists ./fish.nix) ./fish.nix);
}
