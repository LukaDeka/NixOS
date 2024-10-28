{ config, pkgs, ... }:

{
  services.caddy = {
    enable = true;
    virtualHosts = {
      "seafile.lukadeka.com".extraConfig = ''
        tls /etc/ssl/certs/lukadeka.com.pem /etc/ssl/certs/lukadeka.com.key
        reverse_proxy http://127.0.0.1:39998
      '';
    };
  };
}
