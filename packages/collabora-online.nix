{ config, lib, pkgs, inputs, ... }:

let
  domain = config.vars.domain;
  serverNetbirdIp = config.vars.serverNetbirdIp;
  proxyNetbirdIp = config.vars.proxyNetbirdIp;
in
{
  services.collabora-online = {
    enable = true;
    port = 9980;

    # The unstable package is currently broken
    # package = inputs.nixpkgs-stable.legacyPackages.${pkgs.system}.collabora-online;

    settings = {
      server_name = "collabora.${domain}";
      ssl = {
        enable = false;
        termination = true;
      };

      net = {
        listen = "any"; # Default is "any"
        post_allow.host = [ "::1" proxyNetbirdIp serverNetbirdIp ]; # remove server
      };

      # Restrict loading documents from WOPI Host nextcloud.example.com
      storage.wopi = {
        "@allow" = true;
        host = [ "nextcloud.${domain}" "collabora.${domain}" serverNetbirdIp proxyNetbirdIp "127.0.0.1" "::1" ];
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ config.services.collabora-online.port 40080 ];

  services.nginx.virtualHosts."collabora.${domain}" = {
    listen = [{
      addr = serverNetbirdIp;
      port = 40080;
    }];
    forceSSL = false;
    enableACME = false;
    locations."/" = {
      proxyPass = "http://[::1]:${toString config.services.collabora-online.port}";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_set_header Host $host;
      '';
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
      serverNetbirdIp
      proxyNetbirdIp
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
    };
  };

  # Edit /etc/hosts to force Collabora to resolve to localhost
  # networking.hosts = {
  #   "127.0.0.1" = [ "nextcloud.${domain}" "collabora.${domain}" ];
  #   "::1"       = [ "nextcloud.${domain}" "collabora.${domain}" ];
  # };

  # Do not respond to DNS queries from /etc/hosts since Pi-hole is running
  # TODO: test if this breaks anything without Pi-hole running
 # systemd.tmpfiles.rules = [
  #   "f /var/lib/dnsmasq.d/no-hosts.conf 0644 root root - no-hosts"
  # ];
}

