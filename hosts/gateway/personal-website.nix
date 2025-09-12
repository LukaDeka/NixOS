{ config, pkgs, lib, ... }:

let
  domain = config.vars.domain;
in
{
  services.nginx.virtualHosts = {
  #   "http://${domain}" = { # Redirect http to https
  #     listen = [{
  #       addr = "0.0.0.0";
  #       port = 80;
  #     }];
  #     locations."/" = {
  #         return = "301 https://$host$request_uri";
  #     };
  #   };
    "${domain}" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        root = "/var/www/personal-website/";
        # extraConfig = ''
        #   add_header Strict-Transport-Security 'max-age=300; includeSubDomains; preload; always;'
        # '';
      };
    };
    "www.${domain}" = { # Redirect www to root
      forceSSL = true;
      enableACME = true;
      globalRedirect = domain;
    };
  };
}

