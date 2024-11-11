{ config, pkgs, ... }:

{
  services.seafile = {
    enable = true;
    adminEmail = "luka.dekanozishvili1@gmail.com";
    initialAdminPassword = "kacishedissaxinkleshi";
    ccnetSettings.General.SERVICE_URL = "https://seafile.lukadeka.com";
    seafileSettings = {
      history.keep_days = "30";
      quota.default = "50"; # GB
      fileserver.host = "unix:/run/seafile/server.sock";

      # fileserver.database = {
      #   type = "mysql";
      #   host = "127.0.0.1";
      #   port = 8082; # TCP port
      #   user = "root";
      #   password = "root";
      #   db_name = "seafile_db";
      #   connection_charset = "utf8";
      #   max_connections = 100;
      # };
    };

    # dataDir = "/mnt/md0/seafile";
    gc = {
      enable = true;
      dates = [ "Sun 03:00:00" ];
    };
  };

  services.nginx = {
    enable = true;
  };
  services.nginx.virtualHosts."seafile.lukadeka.com" = {
    sslCertificate = "/etc/ssl/certs/lukadeka.com.pem";
    sslCertificateKey = "/etc/ssl/certs/lukadeka.com.key";
    forceSSL = true;
    enableACME = true;
    locations = {
      "/" = {
        proxyPass = "http://unix:/run/seahub/gunicorn.sock";
        extraConfig = ''
          proxy_set_header   Host $host;
          proxy_set_header   X-Real-IP $remote_addr;
          proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header   X-Forwarded-Host $server_name;
          proxy_read_timeout  1200s;
          client_max_body_size 0;
        '';
      };
      "/seafhttp" = {
        proxyPass = "http://unix:/run/seafile/server.sock";
        extraConfig = ''
          rewrite ^/seafhttp(.*)$ $1 break;
          client_max_body_size 0;
          proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_connect_timeout  36000s;
          proxy_read_timeout  36000s;
          proxy_send_timeout  36000s;
          send_timeout  36000s;
        '';
      };
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "luka.dekanozishvili1@gmail.com";
  };
}

