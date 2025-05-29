{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url =        "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
  };

  outputs = { nixpkgs, ... } @ inputs: {
    nixosConfigurations = {
      berlin = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/berlin/configuration.nix

          ######## Server configuration ########
          ./packages/nextcloud.nix
          ./packages/jellyfin.nix # Media server
          ./packages/nginx.nix # Recommended settings
          ./packages/uptime-kuma.nix # Monitoring
          ./packages/craftycontroller.nix
          # ./packages/seafile.nix # File server
          # ./packages/vaultwarden.nix # Password manager

          ######## Networking ########
          ./packages/ssh.nix
          ./packages/pihole.nix # DNS server/adblocker
          ./packages/incus.nix # VMs
          # ./packages/deluge.nix # Torrent client

          ######## Text editors/navigation ########
          ./packages/neovim.nix # Tiny configuration
          # ./packages/fish.nix # TODO: Learn fish

          ######## etc. ########
          ./packages/extra.nix # Battery settings, lid close, git, networking...
          ./packages/aliases.nix # BASH aliases

          ######## Scripts ########
          ./scripts/cloudflare/service.nix # Dynamic IP updater scripts
          ./scripts/zfs/service.nix # Uptime Kuma monitoring
          ./scripts/virtualisation/update-containers.nix # Runs podman pull weekly
          ./scripts/virtualisation/restart-pihole.nix

          ######## User-specific ########
          ./hosts/berlin/wireguard.nix # VPN
          ./hosts/berlin/zfs.nix # Raid
          ./hosts/berlin/printing.nix # Cloud printing advertised to LAN
          ./hosts/berlin/retroarch.nix # Retro game emulation
        ];
      };

      tbilisi = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/tbilisi/configuration.nix

          ######## Server configuration ########
          ./packages/seafile.nix
          # ./packages/nextcloud.nix
          ./packages/uptime-kuma.nix
          ./packages/nginx.nix

          ######## Networking ########
          ./packages/ssh.nix

          ######## Text editors/navigation ########
          ./packages/neovim.nix

          ######## etc. ########
          ./packages/extra.nix
          ./packages/aliases.nix

          ######## Scripts ########
          ./scripts/cloudflare/service.nix
          ./scripts/duckdns/service.nix
          ./scripts/zfs/service.nix

          ######## User-specific ########
          ./hosts/tbilisi/wireguard.nix
          ./hosts/tbilisi/zfs.nix
          ./hosts/tbilisi/printing.nix
        ];
      };
    };
  };
}

