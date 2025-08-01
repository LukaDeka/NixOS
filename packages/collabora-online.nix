{ config, lib, pkgs, inputs, ... }:

let
  domain = config.vars.domain;
  ddnsDomain = config.vars.ddnsDomain;
in
{
  services.collabora-online = {
    enable = true;

    # The unstable package is currently broken
    # package = inputs.nixpkgs-stable.legacyPackages.${pkgs.system}.collabora-online;
    port = 9980; # Default

    settings = {
      server_name = "collabora.${domain}";
      ssl = {
        enable = false;
        termination = true;
      };

      net = {
        listen = "any"; # Default is "any"
        post_allow.host = [ "0.0.0.0" ];
      };

      # Restrict loading documents from WOPI Host nextcloud.example.com
      storage.wopi = {
        "@allow" = true;
        host = [ "nextcloud.${domain}" ];
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ config.services.collabora-online.port ];

  # services.nginx.virtualHosts = {
  #   "collabora.${domain}" = {
  #     listen = [{
  #       addr = "0.0.0.0";
  #       port = 80;
  #     }];
  #     forceSSL = false;
  #     enableACME = false;
  #     locations."/" = {
  #       proxyPass = "http://[::1]:${toString config.services.collabora-online.port}";
  #       proxyWebsockets = true;
  #     };
  #   };
  # };

  # Systemd unit to set Collabora options using occ
  systemd.services.nextcloud-config-collabora = let
    inherit (config.services.nextcloud) occ;

    # wopi_url = "http://[::1]:${toString config.services.collabora-online.port}";
    public_wopi_url = "https://collabora.${domain}";
    wopi_url = public_wopi_url;
    wopi_allowlist = lib.concatStringsSep "," [
      "100.124.117.109"
      # "127.0.0.1"
      # "::1"
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
    "100.124.117.109" = [ "nextcloud.${domain}" "collabora.${domain}" ];
    # "127.0.0.1" =       [ "nextcloud.${domain}" "collabora.${domain}" ];
    # "::1" =             [ "nextcloud.${domain}" "collabora.${domain}" ];
  };

  # Do not respond to DNS queries from /etc/hosts since Pi-hole is running
  # TODO: test if this breaks anything without Pi-hole running
  systemd.tmpfiles.rules = [
    "f /var/lib/dnsmasq.d/no-hosts.conf 0644 root root - no-hosts"
  ];
}

