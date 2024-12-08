{ config, pkgs, ... }:

let
  domain = config.vars.domain;
  email = config.vars.email;
in
{
  services.vaultwarden = {
    enable = true;
    environmentFile = "/etc/env/vaultwarden/secrets";
    # dbBackend = "postgresql"; # TODO: Move to ZFS pool
    backupDir = "/var/backup/vaultwarden";
    config = {
      DOMAIN = "https://vaultwarden.${domain}";
      SIGNUPS_ALLOWED = false;

      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;

      ROCKET_LOG = "critical";

      # This example assumes a mailserver running on localhost,
      # thus without transport encryption.
      # If you use an external mail server, follow:
      #   https://github.com/dani-garcia/vaultwarden/wiki/SMTP-configuration
      #SMTP_HOST = "127.0.0.1";
      #SMTP_PORT = 25;
      #SMTP_SSL = false;

      #SMTP_FROM = "admin@bitwarden.example.com";
      #SMTP_FROM_NAME = "example.com Bitwarden server";
    };
  };

  services.nginx.virtualHosts."vaultwarden.${domain}" = {
    enableACME = true;
    forceSSL = true;
    sslCertificate = "/etc/env/ssl/${domain}.pem";
    sslCertificateKey = "/etc/env/ssl/${domain}.key";
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.vaultwarden.config.ROCKET_PORT}";
    };
  };

  security.acme = {
    acceptTerms = true;
    certs = {
      "vaultwarden.${domain}".email = email;
    };
  };
}

