{ config, lib, pkgs, ... }:

let
  domain = config.vars.domain;
  ddnsDomain = config.vars.ddnsDomain;
in
{
  services.collabora-online = {
    enable = true;
    port = 9980; # Default
    settings = {
      # Rely on reverse proxy for SSL
      ssl = {
        enable = false;
        termination = true;
      };

      # Listen on loopback interface only and accept requests from ::1
      net = {
        listen = "loopback";
        post_allow.host = ["::1"];
      };

      # Restrict loading documents from WOPI Host nextcloud.example.com
      storage.wopi = {
        "@allow" = true;
        host = ["nextcloud.${domain}"];
      };

      # Set FQDN of server
      server_name = "collabora.${domain}";
    };
  };

  services.nginx.virtualHosts = {
    "collabora.${domain}" = {
      sslCertificate = "/etc/env/ssl/${domain}.pem";
      sslCertificateKey = "/etc/env/ssl/${domain}.key";
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://[::1]:${toString config.services.collabora-online.port}";
        proxyWebsockets = true;
      };
    };
  };

  # Systemd unit to set Collabora options using occ
  systemd.services.nextcloud-config-collabora = let
    inherit (config.services.nextcloud) occ;

    wopi_url = "http://[::1]:${toString config.services.collabora-online.port}";
    public_wopi_url = "https://collabora.${domain}";
    wopi_allowlist = lib.concatStringsSep "," [
      "127.0.0.1"
      "::1"
      # "${ddnsDomain}"
    ];
  in {
    wantedBy = [ "multi-user.target" ];
    after = [ "nextcloud-setup.service" "coolwsd.service" ];
    requires = [ "coolwsd.service" ];
    script = ''
      ${occ}/bin/nextcloud-occ config:app:set richdocuments wopi_url --value ${lib.escapeShellArg wopi_url}
      ${occ}/bin/nextcloud-occ config:app:set richdocuments public_wopi_url --value ${lib.escapeShellArg public_wopi_url}
      ${occ}/bin/nextcloud-occ config:app:set richdocuments wopi_allowlist --value ${lib.escapeShellArg wopi_allowlist}
      ${occ}/bin/nextcloud-occ richdocuments:setup
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "nextcloud";
    };
  };

  # Edit /etc/hosts to force Collabora to resolve to localhost
  networking.hosts = {
    "127.0.0.1" = ["nextcloud.${domain}" "collabora.${domain}"];
    "::1" =       ["nextcloud.${domain}" "collabora.${domain}"];
  };
}

