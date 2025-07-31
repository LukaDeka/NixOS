{ config, ... }:

let
  domain = config.vars.domain;
  ip = config.vars.serverNetbirdIp;
in
{
  services.nginx.virtualHosts."collabora.${domain}" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://${ip}:${toString config.services.collabora-online.port}";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
      '';
    };
  };
}

  # services.nginx.virtualHosts = {
  #   "collabora.${domain}" = {
  #     listen = [{
  #       addr = "0.0.0.0";
  #       port = 80;
  #     }];
  #     forceSSL = false;
  #     enableACME = false;
  #     locations."/" = {
  #       proxyPass = "http://[::1]:${toString config.services.collabora-online.port}";
  #       proxyWebsockets = true;
  #     };
  #   };
  # };
