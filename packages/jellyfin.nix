{ config, pkgs, ... }:

let
  domain = config.vars.domain;
  ip = config.vars.ip;
in
{
  services.jellyfin = {
    enable = true;
    openFirewall = true;
    user = config.vars.username;
    # dataDir = "${config.vars.storageDir}/jellyfin";
  };

  services.nginx.virtualHosts = {
    "jellyfin.${domain}" = {
      sslCertificate = "/etc/env/ssl/${domain}.pem";
      sslCertificateKey = "/etc/env/ssl/${domain}.key";
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://${ip}:8096";
        proxyWebsockets = true;
      };
    };
  };
}

