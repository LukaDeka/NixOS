{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url =        "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";
  };

  outputs = { nixpkgs, nixpkgs-stable, ... } @ inputs: {
    nixosConfigurations = {
      conway = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ######## User-specific ########
          ./hosts/conway/configuration.nix
          ./hosts/conway/zfs.nix # Raid
          ./hosts/conway/printing.nix # Cloud printing advertised to LAN
          ./hosts/conway/restic-client.nix

          ######## Server configuration ########
          ./packages/nextcloud.nix
          ./packages/jellyfin.nix # Media server
          ./packages/nginx.nix # Recommended settings
          ./packages/uptime-kuma.nix # Monitoring
          ./packages/retroarch.nix # Retro game emulation
          # ./packages/craftycontroller.nix

          ######## Networking ########
          ./packages/tailscale.nix
          ./packages/server-ssh.nix
          ./packages/pihole.nix # DNS server/adblocker
          ./packages/incus.nix # VM management

          ######## Text editors/navigation ########
          ./packages/neovim.nix
          # ./packages/code-server.nix
          # ./packages/fish.nix # TODO: Learn fish

          ######## etc. ########
          ./packages/common-packages.nix
          ./packages/extra.nix
          ./packages/aliases.nix # BASH aliases
          ./packages/virtualisation.nix

          ######## Scripts ########
          ./scripts/zfs-healthcheck/service.nix # Uptime Kuma monitoring
          ./scripts/virtualisation/update-containers.nix # Runs podman pull weekly
          ./scripts/virtualisation/restart-pihole.nix
        ];
      };

      tbilisi = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ######## User-specific ########
          ./hosts/tbilisi/configuration.nix

          ./hosts/tbilisi/zfs.nix
          ./hosts/tbilisi/printing.nix
          ./hosts/tbilisi/restic-client.nix

          ######## Server configuration ########
          ./packages/nextcloud-ip.nix
          ./packages/uptime-kuma.nix
          ./packages/nginx.nix

          ######## Networking ########
          ./packages/tailscale.nix
          ./packages/server-ssh.nix
          # ./packages/frigate-podman.nix

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

      gateway = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ######## User-specific ########
          ./hosts/gateway/configuration.nix
          ./hosts/gateway/ssh.nix
          ./hosts/gateway/personal-website.nix
          ./hosts/gateway/restic-client.nix

          ######## Networking ########
          ./packages/tailscale.nix
          # ./packages/netbird.nix
          ./packages/nginx.nix
          ./packages/nextcloud-vps.nix
          # ./packages/collabora-online-vps.nix
          ./packages/jellyfin-vps.nix
          # ./packages/code-server-vps.nix
          ./packages/stalwart.nix
          # ./packages/vaultwarden.nix # Password manager

          ######## Text editors/navigation ########
          ./packages/neovim.nix

          ######## etc. ########
          ./packages/common-packages.nix
          ./packages/extra.nix
          ./packages/aliases.nix
          ./packages/virtualisation.nix

          ######## Scripts ########
          ./scripts/virtualisation/update-containers.nix
          # ./scripts/virtualisation/restart-netbird-relay.nix
        ];
      };
    };
  };
}

