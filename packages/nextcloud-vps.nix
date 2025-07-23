{ config, pkgs, ... }:

let
  domain = config.vars.domain;
in
{
  services.nginx.virtualHosts = {
    "nextcloud.${domain}" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://100.124.116.159";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          client_max_body_size 50G;
        '';
      };
    };
    # "${domain}" = { # Redirect root domain to Nextcloud subdomain
    #   forceSSL = true;
    #   enableACME = true;
    #   globalRedirect = "nextcloud.${domain}";
    # };
  };
}

