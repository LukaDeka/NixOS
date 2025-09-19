{ config, pkgs, ... }:

{
  services.nginx = {
    enable = true;

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;
    # recommendedProxySettings = true;

    # Only allow PFS-enabled ciphers with AES256
    sslCiphers = "AES256+EECDH:AES256+EDH:!aNULL";

    appendHttpConfig = ''
      # Minimize information leaked to other domains
      add_header 'Referrer-Policy' 'origin-when-cross-origin';

      # Disable embedding as a frame
      add_header X-Frame-Options SAMEORIGIN;

      # Prevent injection of code in other mime types (XSS Attacks)
      add_header X-Content-Type-Options nosniff;

      # error_log /var/log/nginx/error.log debug;
      # error_log stderr;
      # access_log syslog:server=unix:/dev/log combined;
    '';
  };

   security.acme = {
     acceptTerms = true;
     defaults.email = config.vars.email;
   };

   networking.firewall = {
     enable = true;
     allowedTCPPorts = [ 80 443 ];
   };
}

