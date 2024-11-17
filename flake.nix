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
          ######## Server configuration ########
          ./modules/nextcloud.nix
          # ./modules/seafile.nix    # TODO: Fix Seafile
          # ./modules/samba.nix      # TODO: Figure out what to do with Samba
          ./modules/printing.nix

          ######## Networking ########
          ./modules/wireguard.nix  # VPN
          ./modules/ssh.nix

          # ./modules/blocky.nix     # DNS server/adblocker TODO: Diagnose why it's not working/switch to Pihole Docker container
          # ./modules/nginx.nix      
          # ./modules/caddy.nix
          # ./modules/docker.nix

          ######## etc. ########
          # ./modules/neovim.nix
          # ./modules/nixvim.nix
          # ./modules/fish.nix       # TODO: Learn fish
          ./scripts/scripts.nix
          ./modules/variables.nix
          ./modules/extra.nix      # Battery settings, lid close, fonts...
          ./modules/aliases.nix    # BASH aliases
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

