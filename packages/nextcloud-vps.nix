{ config, ... }:

let
  domain = config.vars.domain;
  ip = config.vars.serverNetbirdIp;
in
{
  services.nginx.virtualHosts."nextcloud.${domain}" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://${ip}:80";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        client_max_body_size 50G;
      '';
    };
  };
}

