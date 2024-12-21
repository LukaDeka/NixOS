{ config, pkgs, ... }:

let
  domain = config.vars.domain;
  ip = config.vars.ip;
in
{
  services.uptime-kuma = {
    enable = true;
    settings = {
      NODE_EXTRA_CA_CERTS = "/etc/env/ssl/${domain}.pem";
      PORT = "4000";
      HOST = "${ip}";
    };
  };

  networking.firewall.allowedTCPPorts = [ 4000 ];
}

