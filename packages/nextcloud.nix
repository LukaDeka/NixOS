{ config, pkgs, ... }:

let
  storageDir = config.vars.storageDir;
  domain =     config.vars.domain;
  username =   config.vars.username;
  email =      config.vars.email;
  ip =         config.vars.ip;
in
{
  services.postgresql = {
    enable = true;
    dataDir = "${storageDir}/postgresql/${config.services.postgresql.package.psqlSchema}";
  };

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud30;

    hostName = "nextcloud.${domain}";
    https = true;

    configureRedis = true;
    database.createLocally = true;
    maxUploadSize = "50G";

    datadir = "${storageDir}/nextcloud";
    home = "${storageDir}/nextcloud";

    config = {
      dbtype = "pgsql";

      adminuser = email;
      adminpassFile = "/etc/env/nextcloud/adminpass";
    };

    autoUpdateApps.enable = true;
    extraAppsEnable = true;
    extraApps = with config.services.nextcloud.package.packages.apps; {
      # List of apps we want to install and are already packaged in
      # https://github.com/NixOS/nixpkgs/blob/master/pkgs/servers/nextcloud/packages/nextcloud-apps.json
      inherit calendar contacts deck
        previewgenerator memories maps notes
        end_to_end_encryption unroundedcorners
        polls forms music
        richdocuments # for Collabora online
        mail # TODO: set up Roundcube
        spreed;
    };

    settings = {
      trusted_domains = [ "${ip}" ];
    };
  };

  services.nginx.virtualHosts = {
    "nextcloud.${domain}" = {
      sslCertificate = "/etc/env/ssl/${domain}.pem";
      sslCertificateKey = "/etc/env/ssl/${domain}.key";
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        root = "${storageDir}/nextcloud";
        extraConfig = ''
          fastcgi_split_path_info ^(.+\.php)(/.+)$;
          fastcgi_pass unix:/run/phpfpm/nextcloud.sock;
          include ${pkgs.nginx}/conf/fastcgi_params;
          include ${pkgs.nginx}/conf/fastcgi.conf;
        '';
      };
    };
    # Commented out since cloudflare is NOT updating my DNS records...
    # "${domain}" = { # Redirect root domain to nextcloud subdomain
    #   forceSSL = true;
    #   enableACME = true;
    #   sslCertificate = "/etc/env/ssl/${domain}.pem";
    #   sslCertificateKey = "/etc/env/ssl/${domain}.key";
    #   globalRedirect = "nextcloud.${domain}";
    # };
  };

  security.acme = {
    acceptTerms = true;
    certs = {
      ${config.services.nextcloud.hostName}.email = config.vars.email;
    };
  };
}

