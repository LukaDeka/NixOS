{ config, pkgs, ... }:

let
  ip = config.vars.ip;
in
{
  virtualisation.oci-containers.containers.pihole = {
    image = "pihole/pihole:latest";
    ports = [
      "${ip}:53:53/tcp"
      "${ip}:53:53/udp"
      "3080:80"
      "30443:443"
    ];

    volumes = [
      "/var/lib/pihole/:/etc/pihole/"
      "/var/lib/dnsmasq.d:/etc/dnsmasq.d/"
    ];

    environmentFiles = [ "/etc/env/pihole/envfile" ];

    extraOptions = [
      "--cap-add=NET_ADMIN"
      "--dns=127.0.0.1"
      "--dns=1.1.1.1"
    ];
  };
}

