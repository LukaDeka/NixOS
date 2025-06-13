{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url =        "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, disko, ... } @ inputs: {
    nixosConfigurations = {
      berlin = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ######## User-specific ########
          ./hosts/berlin/configuration.nix
          ./packages/common-packages.nix
          ./packages/laptop-server.nix

          # ./hosts/berlin/wireguard.nix # VPN
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
          ./packages/wireguard-client.nix
          ./packages/virtualization.nix
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
          # ./scripts/cloudflare/service.nix # Dynamic IP updater scripts
          ./scripts/zfs/service.nix # Uptime Kuma monitoring
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
          ./packages/laptop-server.nix
          ./packages/common-packages.nix

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
          ./packages/extra.nix
          ./packages/aliases.nix

          ######## Scripts ########
          ./scripts/cloudflare/service.nix
          ./scripts/zfs/service.nix
        ];
      };

      hetzner = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ######## User-specific ########
          ./hosts/gateway/configuration.nix
          ./hosts/gateway/disk-config.nix
          ./packages/common-packages.nix
          disko.nixosModules.disko

          ######## Networking ########
          ./packages/gateway-ssh.nix
          ./packages/virtualization.nix
          ./packages/wireguard-server.nix

          ######## Text editors/navigation ########
          ./packages/neovim.nix

          ######## etc. ########
          ./packages/extra.nix
          ./packages/aliases.nix
        ];
      };
    };
  };
}

