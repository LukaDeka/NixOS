{ config, pkgs, ... }:

{
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud29;

    hostName = "nextcloud.lukadeka.com";
    https = true;

    configureRedis = true;
    database.createLocally = true;
    maxUploadSize = "50G";

    config = {
      dbtype = "pgsql";
      adminuser = "admin";
      adminpassFile = "/etc/env/nextcloud/adminpass";
    };

    autoUpdateApps.enable = true;
    extraAppsEnable = true;
    extraApps = with config.services.nextcloud.package.packages.apps; {
        # List of apps we want to install and are already packaged in
        # https://github.com/NixOS/nixpkgs/blob/master/pkgs/servers/nextcloud/packages/nextcloud-apps.json
        inherit calendar contacts mail notes onlyoffice tasks;
    };

    settings = let
      # prot = "https"; # or https
      # host = "nextcloud.lukadeka.com";
      # dir = "/nextcloud";
    in {
      trusted_domains = [ "10.10.10.10" ];
      # overwriteprotocol = prot;
      # overwritehost = host;
      # overwritewebroot = dir;
      # overwrite.cli.url = "${prot}://${host}${dir}/";
      # htaccess.RewriteBase = dir;
    };
  };

#  services.onlyoffice = {
#    enable = true;
#    hostname = "onlyoffice.lukadeka.com";
#  };

  services.nginx.virtualHosts.${config.services.nextcloud.hostName} = {
    forceSSL = true;
    enableACME = true;
    sslCertificate = "/etc/ssl/certs/lukadeka.com.pem"; # TODO: update location
    sslCertificateKey = "/etc/ssl/certs/lukadeka.com.key";
    #listen = [ {
    #  addr = "127.0.0.1";
    #  port = 39997; # NOT an exposed port
    #} ];
  };

  security.acme = {
    acceptTerms = true;   
    certs = { 
      ${config.services.nextcloud.hostName}.email = "luka.dekanozishvili1@gmail.com";
    }; 
  };

#  services.nginx.virtualHosts."localhost".listen = [ {
#    addr = "127.0.0.1";
#    port = 39996;
#  } ];

#  services.nginx.virtualHosts."localhost".locations = {
#    "^~ /.well-known" = {
#      priority = 9000;
#      extraConfig = ''
#        absolute_redirect off;
#        location ~ ^/\\.well-known/(?:carddav|caldav)$ {
#          return 301 /nextcloud/remote.php/dav;
#        }
#        location ~ ^/\\.well-known/host-meta(?:\\.json)?$ {
#          return 301 /nextcloud/public.php?service=host-meta-json;
#        }
#        location ~ ^/\\.well-known/(?!acme-challenge|pki-validation) {
#          return 301 /nextcloud/index.php$request_uri;
#        }
#        try_files $uri $uri/ =404;
#      '';
#    };
#  };

#  services.nginx.virtualHosts."localhost".locations = {
#    "/nextcloud/" = {
#      priority = 9999;
#      extraConfig = ''
#        proxy_set_header X-Real-IP $remote_addr;
#        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
#        proxy_set_header X-NginX-Proxy true;
#        proxy_set_header X-Forwarded-Proto http;
#        proxy_pass http://127.0.0.1:39996/; # tailing / is important!
#        proxy_set_header Host $host;
#        proxy_cache_bypass $http_upgrade;
#        proxy_redirect off;
#      '';
#    };
#  };
}
