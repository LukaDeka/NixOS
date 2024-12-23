{
  description = "Nixos config flake";

  inputs = {
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

          ######## Text editors/navigation ########
          ./packages/neovim.nix # Tiny configuration
          # ./packages/fish.nix # TODO: Learn fish

          ######## etc. ########
          ./scripts/scripts.nix # Dynamic IP updater scripts
          ./packages/extra.nix # Battery settings, lid close, git, networking...
          ./packages/aliases.nix # BASH aliases

          ######## User-specific ########
          ./hosts/berlin/zfs.nix # Raid
          ./hosts/berlin/printing.nix # Cloud printing advertised to LAN
        ];
      };

      tbilisi = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/tbilisi/configuration.nix

          ######## Server configuration ########
          #./packages/seafile.nix
          #./packages/nginx.nix
          # ./packages/nextcloud.nix

          ######## Networking ########
          ./packages/ssh.nix
          ./packages/wireguard.nix

          ######## Text editors/navigation ########
          ./packages/neovim.nix

          ######## etc. ########
          ./scripts/scripts.nix
          ./packages/extra.nix
          ./packages/aliases.nix

          ######## User-specific ########
          #./hosts/tbilisi/zfs.nix
        ];
      };
    };
  };
}

