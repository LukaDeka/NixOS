{ config, pkgs, lib, ... }:

let
  storageDir = config.vars.storageDir;
  domain =     config.vars.domain;
  username =   config.vars.username;
  email =      config.vars.email;
  ip =         config.vars.ip;
in
{
  imports = [ ./collabora-online.nix ];
  # imports = [ ./onlyoffice.nix ];

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

    autoUpdateApps.enable = true;
    extraAppsEnable = true;
    extraApps = with config.services.nextcloud.package.packages.apps; {
      # List of apps we want to install and are already packaged in
      # https://github.com/NixOS/nixpkgs/blob/master/pkgs/servers/nextcloud/packages/nextcloud-apps.json
      inherit calendar contacts deck
      previewgenerator memories notes # maps
      end_to_end_encryption unroundedcorners
      forms richdocuments
      # news
      # phonetrack
      # onlyoffice
      # recognize
      spreed;
      # epubviewer = pkgs.fetchNextcloudApp {
      #   url = "https://github.com/devnoname120/epubviewer/releases/download/1.7.3/epubviewer-1.7.3.tar.gz";
      #   sha256 = "sha256-XOU6adVhi2ek7/Ri36XjMre55tfMFGkSLgkUKdGiMNc=";
      #   license = "gpl3";
      # };
      # facerecognition = pkgs.fetchNextcloudApp {
      #   url = "https://github.com/matiasdelellis/facerecognition/archive/refs/tags/v0.9.70.tar.gz";
      #   sha256 = "sha256-yx+nuIDgd6+h5YD5/mT2+IpmuU3aXwGLAFUm67e88aY=";
      #   license = "gpl3";
      # };
      # TODO: wait until snappymail works on NC31
      # snappymail = pkgs.fetchNextcloudApp {
      #   # url = "https://github.com/the-djmaze/snappymail/releases/download/v2.38.2/snappymail-2.38.2.tar.gz";
      #   url = "https://github.com/the-djmaze/snappymail/archive/refs/tags/v2.38.2.tar.gz";
      #   sha256 = "sha256-Jb38nfz8+4tMl4XIIvcW4WrzUi6Ss/uPNGpgv4mElDI=";
      #   license = "gpl3";
      # };
    };

    # pfp-fpm optimization settings. For more details refer to this guide:
    # https://tideways.com/profiler/blog/an-introduction-to-php-fpm-tuning
    poolSettings = {
      pm = "dynamic";
      "pm.max_children" = "129";
      "pm.start_servers" = "32";
      "pm.min_spare_servers" = "32";
      "pm.max_spare_servers" = "96";
    };

    phpOptions = {
      "opcache.interned_strings_buffer" = "32"; # Default is 8 MB
      "opcache.jit" = "1255";
      "opcache.jit_buffer_size" = "8M";
    };

    database.createLocally = true;
    config = {
      dbtype = "pgsql";
      adminuser = email;
      adminpassFile = "/etc/env/nextcloud/adminpass";
    };

    configureRedis = true;
    settings = {
      memcache = {
        local = "\\OC\\Memcache\\Redis";
        distributed = "\\OC\\Memcache\\Redis";
        locking = "\\OC\\Memcache\\Redis";
      };

      trusted_domains = [ "${ip}" ];

      default_phone_region = "DE";
      default_language = "en";
      default_locale = "de_DE";
      reduce_to_languages = [ "en" "de" "ge" "ru" ]; # Only show these languages

      knowledgebaseenabled = false; # Disable help menu
      lost_password_link = "disabled"; # Disable "reset password"
      trashbin_retention_obligation = "auto, 15"; # Delete files after 15 days

      preview_max_x = "2048"; # Save on filesize, default is 4096x4096
      preview_max_y = "2048";

      ldapUserCleanupInterval = "7200"; # Clean up deleted users every 5 days
      upgrade.disable-web = false;

      filesystem_check_changes = "1"; # Check for changes outside of NC
      maintenance_window_start = "1"; # Run BG jobs between 01:00-05:00 UTC
      simpleSignUpLink.shown = "false"; # Remove signup option when sharing
    };
  };

  # Add packages to env path
  systemd.services.nextcloud-cron.path = [ pkgs.ffmpeg pkgs.perl ];

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
    "${domain}" = { # Redirect root domain to nextcloud subdomain
      forceSSL = true;
      enableACME = true;
      sslCertificate = "/etc/env/ssl/${domain}.pem";
      sslCertificateKey = "/etc/env/ssl/${domain}.key";
      globalRedirect = "nextcloud.${domain}";
    };
  };

  security.acme = {
    acceptTerms = true;
    certs = {
      ${config.services.nextcloud.hostName}.email = config.vars.email;
    };
  };
}

