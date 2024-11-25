{ config, pkgs, ... }:

let
  domain = config.vars.domain;
  ip = config.vars.ip;
  email = config.vars.email;
  storageDir = config.vars.storageDir;
in
{
  services.seafile = {
    enable = true;
    adminEmail = email;
    initialAdminPassword = "mananakitrisad";
    ccnetSettings.General.SERVICE_URL = "https://seafile.${domain}";

    # TODO: Figure out how to architect local access
    # seahubAddress = "127.0.0.1:39997";
    seahubExtraConf = ''
      SRF_TRUSTED_ORIGINS = ["https://${domain}","${ip}"]
    '';

    seafileSettings = {
      history.keep_days = "3";
      quota.default = "50"; # Amount of GB allotted to users

      fileserver = {
        # use_go_fileserver = true; # TODO: Diagnose why this option is broken
	host = "unix:/run/seafile/server.sock";
        web_token_expire_time = 18000; # Set max "upload time" to 5h
      };
    };

    dataDir = "${storageDir}/seafile/data";

    gc.enable = true;
  };

  services.nginx.enable = true;
  services.nginx.virtualHosts."seafile.${domain}" = {
    sslCertificate = "/etc/env/ssl/${domain}.pem";
    sslCertificateKey = "/etc/env/ssl/${domain}.key";
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
    defaults.email = email;
  };
}

