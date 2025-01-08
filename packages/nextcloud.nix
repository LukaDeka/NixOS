{ config, pkgs, ... }:

let
  storageDir = config.vars.storageDir;
  domain = config.vars.domain;
  username = config.vars.username;
  ip = config.vars.ip;
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

      adminuser = username; # Your main linux username
      adminpassFile = "/etc/env/nextcloud/adminpass";
    };

    # autoUpdateApps.enable = true;
    # extraAppsEnable = true;
    # extraApps = with config.services.nextcloud.package.packages.apps; {
    #     # List of apps we want to install and are already packaged in
    #     # https://github.com/NixOS/nixpkgs/blob/master/pkgs/servers/nextcloud/packages/nextcloud-apps.json
    #     inherit calendar contacts notes tasks
    #       end_to_end_encryption forms
    #       spreed whiteboard polls onlyoffice mail; # TODO: Fix/test out these apps
    # };

    settings = {
      trusted_domains = [ "${ip}" "nextcloud.${domain}" ];
    };
  };

  # services.onlyoffice = {
  #   enable = false;
  #   port = 39990;
  #   hostname = "onlyoffice.${domain}";
  # };

  # services.nextcloud.webfinger = true;
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
  };


  security.acme = {
    acceptTerms = true;
    certs = {
      ${config.services.nextcloud.hostName}.email = config.vars.email;
    };
  };
}

