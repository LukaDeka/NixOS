{ config, pkgs, ... }:

let
  storageDir = config.vars.storageDir;
  domain =     config.vars.domain;
  username =   config.vars.username;
  email =      config.vars.email;
  ip =         config.vars.ip;
in
{
  imports = [ ./collabora-online.nix ];

  services.postgresql = {
    enable = true;
    dataDir = "${storageDir}/postgresql/${config.services.postgresql.package.psqlSchema}";
  };

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud31;

    hostName = "nextcloud.${domain}";
    https = true;

    datadir = "${storageDir}/nextcloud";
    home = "${storageDir}/nextcloud";

    maxUploadSize = "50G";
    configureRedis = true;
    database.createLocally = true;
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
      previewgenerator memories notes # maps
      end_to_end_encryption unroundedcorners
      polls forms music
      richdocuments
      spreed;
      # TODO: wait until snappymail works on NC31
      # snappymail = pkgs.php.buildComposerProject (finalAttrs: {
      #   pname = "snappymail";
      #   version = "2.38.2";
      #   src = pkgs.fetchFromGitHub {
      #     owner = "the-djmaze";
      #     repo = "snappymail";
      #     rev = "70aebb498188e29e098176e47b7c31c03fc9d20f";
      #     hash = "sha256-s9xWy/yISny43hQBtEJQx5xYLhdISbOBdWKHathtbLU=";
      #   };
      #   composerNoDev = true;
      #   composerNoPlugins = true;
      #   composerNoScripts = true;
      #   vendorHash = "sha256-PCWWu/SqTUGnZXUnXyL8c72p8L14ZUqIxoa5i49XPH4=";
      #   postInstall = ''
      #     cp -r $out/share/php/snappymail/* $out/
      #     rm -r $out/share
      #   '';
      # });
    };
          # snappymail = pkgs.fetchNextcloudApp {
          #   # url = "https://github.com/the-djmaze/snappymail/releases/download/v2.38.2/snappymail-2.38.2.tar.gz";
          #   url = "https://github.com/the-djmaze/snappymail/archive/refs/tags/v2.38.2.tar.gz";
          #   sha256 = "sha256-Jb38nfz8+4tMl4XIIvcW4WrzUi6Ss/uPNGpgv4mElDI=";
          #   license = "gpl3";
          # };

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

