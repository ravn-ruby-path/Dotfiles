# ═══════════════════════════════════════════════════════════════
# 📦 SOFTWARE - TERMINAL SOFTWARE MODULE AGGREGATOR
# ═══════════════════════════════════════════════════════════════
{lib, ...}: {
  imports =
    [
      ./gh.nix
      ./git.nix
      ./scripts.nix
    ]
    ++ (lib.optional (builtins.pathExists ./atuin.nix) ./atuin.nix)
    ++ (lib.optional (builtins.pathExists ./bat.nix) ./bat.nix)
    ++ (lib.optional (builtins.pathExists ./lazygit.nix) ./lazygit.nix)
    ++ (lib.optional (builtins.pathExists ./nix-your-shell.nix) ./nix-your-shell.nix)
    ++ (lib.optional (builtins.pathExists ./skim.nix) ./skim.nix)
    ++ (lib.optional (builtins.pathExists ./yazi/default.nix) ./yazi/default.nix)
    ++ (lib.optional (builtins.pathExists ./zoxide.nix) ./zoxide.nix);
}
