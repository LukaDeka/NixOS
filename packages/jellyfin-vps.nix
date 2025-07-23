{ config, pkgs, ... }:

let
  domain = config.vars.domain;
  ip = "100.124.116.159";
in
{
  services.nginx.virtualHosts = {
    "jellyfin.${domain}" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://${ip}:8096";
        proxyWebsockets = true;
      };
    };
  };
}

