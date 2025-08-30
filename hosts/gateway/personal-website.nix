{ config, pkgs, lib, ... }:

let
  domain = config.vars.domain;
in
{
  services.nginx.virtualHosts.${domain} = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      root = "/var/www/personal-website/";
    };
  };
}

