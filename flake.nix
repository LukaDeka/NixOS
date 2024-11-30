{
  description = "Nixos config flake";

  inputs = {
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # nixvim.url = "github:nix-community/nixvim";
    # nixvim.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, ... } @ inputs: {
    nixosConfigurations = {

      berlin = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/berlin/configuration.nix

          ######## Server configuration ########
          ./packages/seafile.nix
          ./packages/nextcloud.nix
          ./packages/jellyfin.nix
          ./packages/vaultwarden.nix
          ./packages/nginx.nix # Recommended settings

          ######## Networking ########
          ./packages/wireguard.nix # VPN
          ./packages/ssh.nix
          ./packages/deluge.nix # Torrent client

          # ./packages/blocky.nix # TODO: Switch to Pihole Docker container
          # ./packages/samba.nix # TODO: Figure out what to do with Samba
          # ./packages/caddy.nix
          # ./packages/docker.nix

          ######## Text editors/navigation ########
          # ./packages/neovim.nix
          # ./packages/nixvim.nix
          # ./packages/fish.nix # TODO: Learn fish

          ######## etc. ########
          ./scripts/scripts.nix
          ./packages/variables.nix
          ./packages/extra.nix # Battery settings, lid close, git, networking...
          ./packages/aliases.nix # BASH aliases

          ######## User-specific ########
          ./hosts/berlin/printing.nix # Cloud printing advertised to LAN
          ./hosts/berlin/zfs.nix # Raid
        ];
      };

      tbilisi = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/tbilisi/configuration.nix

          ######## Server configuration ########
          # ./packages/nextcloud.nix
          # ./packages/seafile.nix
          # ./packages/vaultwarden.nix

          ######## Networking ########
          ./packages/wireguard.nix
          ./packages/ssh.nix

          ######## etc. ########
          ./scripts/scripts.nix
          ./packages/variables.nix
          ./packages/extra.nix
          ./packages/aliases.nix
          # ./hosts/tbilisi/zfs.nix
        ];
      };
    };
  };
}

