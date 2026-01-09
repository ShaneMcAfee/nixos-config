{
  description = "Framework 16 Ryzen AI 300 NixOS Config";

  inputs = {
    # NixOS Unstable Channel
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Hardware Quirks for Framework
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # Home Manager (Follows Nixpkgs version)
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-hardware, home-manager, ... }@inputs: {
    nixosConfigurations.framework16 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {inherit inputs;};
      modules = [
        ./hardware-configuration.nix
        ./configuration.nix
        nixos-hardware.nixosModules.framework-16-amd-ai-300-series
        
        # Enable Home Manager Module
        home-manager.nixosModules.default
      ];
    };
  };
}
