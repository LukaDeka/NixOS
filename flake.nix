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
          ./packages/nextcloud.nix
          # ./packages/seafile.nix    # TODO: Fix Seafile
          # ./packages/samba.nix      # TODO: Figure out what to do with Samba
          ./packages/printing.nix

          ######## Networking ########
          ./packages/wireguard.nix  # VPN
          ./packages/ssh.nix

          # ./packages/blocky.nix     # DNS server/adblocker TODO: Diagnose why it's not working/switch to Pihole Docker container
          # ./packages/nginx.nix      
          # ./packages/caddy.nix
          # ./packages/docker.nix

          ######## etc. ########
          # ./packages/neovim.nix
          # ./packages/nixvim.nix
          # ./packages/fish.nix       # TODO: Learn fish
          ./scripts/scripts.nix
          ./packages/variables.nix
          ./packages/extra.nix      # Battery settings, lid close, fonts...
          ./packages/aliases.nix    # BASH aliases
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

