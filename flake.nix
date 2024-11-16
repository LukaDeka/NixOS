{
  description = "Nixos config flake";

  inputs = {
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # nixvim.url = "github:nix-community/nixvim";
    # nixvim.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, ... } @ inputs:
  let

  in {
    nixosConfigurations = {

      berlin = nixpkgs.lib.nixosSystem {
	system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/berlin/configuration.nix
	  #./modules/nixvim.nix
        ];
      };

      tbilisi = nixpkgs.lib.nixosSystem {
	system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/tbilisi/configuration.nix
        ];
      };
    };
  };
}

