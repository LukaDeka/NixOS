{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url =        "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";
    nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver/master";
  };

  outputs = { nixpkgs, nixpkgs-stable, nixos-mailserver, ... } @ inputs: {
    nixosConfigurations = {
      berlin = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ######## User-specific ########
          ./hosts/berlin/configuration.nix

          # ./hosts/berlin/wireguard.nix # VPN to home server
          ./hosts/berlin/zfs.nix # Raid
          ./hosts/berlin/printing.nix # Cloud printing advertised to LAN


          ######## Server configuration ########
          ./packages/nextcloud.nix
          ./packages/jellyfin.nix # Media server
          ./packages/nginx.nix # Recommended settings
          ./packages/uptime-kuma.nix # Monitoring
          ./packages/retroarch.nix # Retro game emulation
          ./packages/craftycontroller.nix
          # ./packages/seafile.nix # File server
          # ./packages/vaultwarden.nix # Password manager

          ######## Networking ########
          ./packages/server-ssh.nix
          ./packages/pihole.nix # DNS server/adblocker
          ./packages/incus.nix # VM management
          # ./packages/deluge.nix # Torrent client

          ######## Text editors/navigation ########
          ./packages/neovim.nix # Tiny configuration
          # ./packages/fish.nix # TODO: Learn fish

          ######## etc. ########
          ./packages/common-packages.nix
          ./packages/laptop-server.nix
          ./packages/extra.nix
          ./packages/aliases.nix # BASH aliases
          ./packages/virtualisation.nix

          ######## Scripts ########
          ./scripts/zfs-healthcheck/service.nix # Uptime Kuma monitoring
          ./scripts/virtualisation/update-containers.nix # Runs podman pull weekly
          ./scripts/virtualisation/restart-pihole.nix
        ];
      };

      conway = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ######## User-specific ########
          ./hosts/conway/configuration.nix

          # ./hosts/berlin/wireguard.nix # VPN to home server
          ./hosts/conway/zfs.nix # Raid
          # ./hosts/conway/printing.nix # Cloud printing advertised to LAN


          ######## Server configuration ########
          # ./packages/nextcloud.nix
          # ./packages/jellyfin.nix # Media server
          # ./packages/nginx.nix # Recommended settings
          # ./packages/uptime-kuma.nix # Monitoring
          # ./packages/retroarch.nix # Retro game emulation
          # ./packages/craftycontroller.nix
          # ./packages/vaultwarden.nix # Password manager

          ######## Networking ########
          ./packages/server-ssh.nix
          # ./packages/pihole.nix # DNS server/adblocker
          # ./packages/incus.nix # VM management
          # ./packages/deluge.nix # Torrent client

          ######## Text editors/navigation ########
          ./packages/neovim.nix # Tiny configuration
          # ./packages/fish.nix # TODO: Learn fish

          ######## etc. ########
          ./packages/common-packages.nix
          ./packages/extra.nix
          ./packages/aliases.nix # BASH aliases
          ./packages/virtualisation.nix

          ######## Scripts ########
          # ./scripts/zfs-healthcheck/service.nix # Uptime Kuma monitoring
          # ./scripts/virtualisation/update-containers.nix # Runs podman pull weekly
          # ./scripts/virtualisation/restart-pihole.nix
        ];
      };

      tbilisi = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ######## User-specific ########
          ./hosts/tbilisi/configuration.nix

          ./hosts/tbilisi/wireguard.nix
          ./hosts/tbilisi/zfs.nix
          ./hosts/tbilisi/printing.nix

          ######## Server configuration ########
          ./packages/seafile.nix
          # ./packages/nextcloud.nix
          ./packages/uptime-kuma.nix
          ./packages/nginx.nix

          ######## Networking ########
          ./packages/server-ssh.nix

          ######## Text editors/navigation ########
          ./packages/neovim.nix

          ######## etc. ########
          ./packages/common-packages.nix
          ./packages/laptop-server.nix
          ./packages/extra.nix
          ./packages/aliases.nix

          ######## Scripts ########
          ./scripts/cloudflare/service.nix # Dynamic IP updater scripts
          ./scripts/zfs-healthcheck/service.nix
        ];
      };

      hetzner = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          nixos-mailserver.nixosModule
          ######## User-specific ########
          ./hosts/gateway/configuration.nix
          ./hosts/gateway/ssh.nix

          ######## Networking ########
          ./packages/netbird.nix
          ./packages/nextcloud-vps.nix
          # ./packages/collabora-online-vps.nix
          ./packages/jellyfin-vps.nix
          ./packages/mailserver.nix

          ######## Text editors/navigation ########
          ./packages/neovim.nix

          ######## etc. ########
          ./packages/common-packages.nix
          ./packages/extra.nix
          ./packages/aliases.nix
          ./packages/virtualisation.nix
        ];
      };
    };
  };
}

