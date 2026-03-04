# ═══════════════════════════════════════════════════════════════
# ❄️  FLAKE - NIXOS SYSTEM ENTRYPOINT
# ═══════════════════════════════════════════════════════════════
{
  description = "template for hydenix";

  # ──── Inputs: External Dependencies ──────────────────────────────
  inputs = {
    nixpkgs = {
      # url = "github:nixos/nixpkgs/nixos-unstable"; # uncomment to use your own nixpkgs
      follows = "hydenix/nixpkgs"; # tracks hydenix's tested nixpkgs revision
    };
    hydenix.url = "github:richen604/hydenix";
    nixos-hardware.url = "github:nixos/nixos-hardware/master";
  };

  # ──── Outputs: System Configurations and VM ────────────────────────
  outputs = inputs: let
    hydenixConfig = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit inputs;
      };
      modules = [
        ./configuration.nix
      ];
    };
    vmConfig = inputs.hydenix.lib.vmConfig {
      inherit inputs;
      nixosConfiguration = hydenixConfig;
    };
  in {
    # === NixOS Configurations ===
    nixosConfigurations.hydenix = hydenixConfig;
    nixosConfigurations.default = hydenixConfig;

    # === VM Build Target ===
    packages."x86_64-linux".vm = vmConfig.config.system.build.vm;
  };
}
