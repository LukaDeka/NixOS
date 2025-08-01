{ config, lib, ... }:

let
  domain = config.vars.domain;
  username = config.vars.username;
in
{
  services.zitadel = {
    enable = true;
    openFirewall = true;
    masterKeyFile = "/etc/env/zitadel/master_key";
    extraStepsPaths = [ "/etc/env/zitadel/admin_steps" ];
    extraSettingsPaths = [ "/etc/env/zitadel/settings" ];

    tlsMode = "external";
    settings = {
      Port = 39995;
      ExternalPort = 443;
      ExternalDomain = "auth.${domain}";
      Database = {
        postgres = {
          Host = "127.0.0.1";
          Port = 5432;
          Database = "zitadel";
          MaxOpenConns = 15;
          MaxIdleConns = 10;
          MaxConnLifetime = "1h";
          MaxConnIdleTime = "5m";
          # Users and passwords are set in the "settings" env file.
          # See ./env-template/zitadel/settings for an example.
          # TODO: Actually create this template file
        };
      };
    };
  };


  virtualisation.oci-containers.containers.zitadel-db = {
    image = "postgres:17";
    ports = [ "5432:5432" ];
    environmentFiles = [
      "/etc/env/zitadel/postgres_env"
    ];
    volumes = [
      "/var/lib/zitadel-db:/var/lib/postgresql/data"
    ];
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  # Make mounted dir
  system.activationScripts.makeZitadelDir = lib.stringAfter [ "var" ] ''
    mkdir -p /var/lib/zitadel-db
  '';

  services.nginx.enable = true;
  services.nginx.virtualHosts."auth.${domain}" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:39995";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
      '';
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = config.vars.email;
  };
}

