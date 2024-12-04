{
  description = "Nixos config flake";

  inputs = {
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { nixpkgs, ... } @ inputs: {
    nixosConfigurations = {

      berlin = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/berlin/configuration.nix

          ######## Server configuration ########
          ./packages/seafile.nix # File server
          ./packages/nextcloud.nix
          ./packages/jellyfin.nix # Media server
          ./packages/vaultwarden.nix # Password manager
          ./packages/nginx.nix # Recommended settings

          ######## Networking ########
          ./packages/ssh.nix
          ./packages/wireguard.nix # VPN
          ./packages/pihole.nix # DNS server/adblocker
          ./packages/deluge.nix # Torrent client

          # ./packages/samba.nix # TODO: Figure out what to do with Samba

          ######## Text editors/navigation ########
          ./packages/neovim.nix # Tiny configuration
          # ./packages/fish.nix # TODO: Learn fish

          ######## etc. ########
          ./scripts/scripts.nix # Dynamic IP updater scripts
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
          ./packages/extra.nix
          ./packages/aliases.nix
          # ./hosts/tbilisi/zfs.nix
        ];
      };
    };
  };
}

