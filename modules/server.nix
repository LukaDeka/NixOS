{ config, pkgs, lib, ... }:

{
  imports = [
    ../packages/seafile.nix
    ../packages/nextcloud.nix
    ../packages/vaultwarden.nix
    ../packages/wireguard.nix
    ../packages/nginx.nix
  ];
}

