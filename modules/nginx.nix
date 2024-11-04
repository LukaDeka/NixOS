{ config, pkgs, ... }:

{
  services.nginx = {
    enable = true;

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    # Only allow PFS-enabled ciphers with AES256
    sslCiphers = "AES256+EECDH:AES256+EDH:!aNULL";

    appendHttpConfig = ''
      # Minimize information leaked to other domains
      add_header 'Referrer-Policy' 'origin-when-cross-origin';

      # Disable embedding as a frame
      add_header X-Frame-Options DENY;

      # Prevent injection of code in other mime types (XSS Attacks)
      add_header X-Content-Type-Options nosniff;

      # error_log /var/log/nginx/error.log debug;
      # error_log stderr;
      # access_log syslog:server=unix:/dev/log combined;
    '';

    virtualHosts."seafile.lukadeka.com" = {
      forceSSL = true;
      sslCertificate = "/etc/ssl/certs/lukadeka.com.pem";
      sslCertificateKey = "/etc/ssl/certs/lukadeka.com.key";
      enableACME = true;

      locations."/" = {
        proxyPass = "http://127.0.0.1:39998";
	proxyWebsockets = true;
	extraConfig = ''
          proxy_set_header   Host $host;
          proxy_set_header   X-Real-IP $remote_addr;
          proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
	  proxy_set_header   X-Forwarded-Host $server_name;
	  proxy_read_timeout  1200s;

         # used for view/edit office file via Office Online Server
         client_max_body_size 0;
	'';
      };
      locations."/seafhttp" = {
        proxyPass = "http://127.0.0.1:8082";
	proxyWebsockets = true;
	extraConfig = ''
	  rewrite ^/seafhttp(.*)$ $1 break;
	  client_max_body_size 0;
          proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;

          proxy_connect_timeout  36000s;
          proxy_read_timeout  36000s;
          proxy_send_timeout  36000s;

          send_timeout  36000s;

          #access_log      /var/log/nginx/seafhttp.access.log seafileformat;
          #error_log       /var/log/nginx/seafhttp.error.log;
	'';
      };
      locations."/media" = {
        root = "/var/lib/seafile/seahub";
      };
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "luka.dekanozishvili1@gmail.com";
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 ];
  };
}
