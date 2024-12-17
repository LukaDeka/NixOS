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

    # TODO: Figure out how to architect local access with proxy
    # seahubAddress = "127.0.0.1:39997";
    seahubExtraConf =
    let
      password_min_len = "10";
      password_unique_chars = "2";
      expire_link_in_max_days = "14";
      expire_link_in_default_days = "5";
    in ''
      SRF_TRUSTED_ORIGINS = ["https://${domain}","${ip}"]

      SITE_TITLE = 'Private Seafile'

      # User password settings
      USER_PASSWORD_MIN_LENGTH = ${password_min_len}
      USER_PASSWORD_STRENGTH_LEVEL = ${password_unique_chars}
      REPO_PASSWORD_MIN_LENGTH = ${password_min_len}

      # User shared link settings
      SHARE_LINK_FORCE_USE_PASSWORD = True
      SHARE_LINK_PASSWORD_MIN_LENGTH = ${password_min_len}
      SHARE_LINK_PASSWORD_STRENGTH_LEVEL = ${password_unique_chars}
      SHARE_LINK_EXPIRE_DAYS_DEFAULT = ${expire_link_in_default_days}
      SHARE_LINK_EXPIRE_DAYS_MAX = ${expire_link_in_max_days}
      UPLOAD_LINK_EXPIRE_DAYS_DEFAULT = ${expire_link_in_default_days}
      UPLOAD_LINK_EXPIRE_DAYS_MAX = ${expire_link_in_max_days}

    '';

    seafileSettings = {
      quota.default = "50"; # Amount of GB allotted to users
      history.keep_days = "3";
      library_trash.expire_days = "3"; # Automatic cleanup of trash

      fileserver = {
        host = "unix:/run/seafile/server.sock";
        web_token_expire_time = 18000; # Set max "upload time" to 5h
      };
    };

    dataDir = "${storageDir}/seafile/data";

    gc = {
      enable = true;
      dates = [ "Sun 03:00:00" ];
    };
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

