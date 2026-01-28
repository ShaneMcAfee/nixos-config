{
  description = "Framework 16 Ryzen AI 300 NixOS Config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Solaar (Logitech Manager)
    solaar = {
      url = "https://flakehub.com/f/Svenum/Solaar-Flake/*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-hardware, home-manager, solaar, ... }@inputs: {
    nixosConfigurations.framework16 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {inherit inputs;};
      modules = [
        ./hosts/framework16/hardware-configuration.nix
        ./hosts/framework16/configuration.nix
        nixos-hardware.nixosModules.framework-16-amd-ai-300-series
        
        # Modules
        home-manager.nixosModules.default
        solaar.nixosModules.default
      ];
    };
  };
}
