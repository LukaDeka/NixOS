{ config, pkgs, lib, ... }:

let
  # ip = config.vars.privateIp;
  ip = "10.10.10.10";
  domain = config.vars.domain;

  # localRecords = ''
  #   address=/${domain}/${ip}
  #   address=/nextcloud.${domain}/${ip}
  #   address=/jellyfin.${domain}/${ip}
  #   address=/ddns.${domain}/${ip}
  # '';
in
{
  virtualisation.oci-containers.containers.pihole = {
    image = "pihole/pihole:latest";
    ports = [
      # "${ip}:53:53"
      # "${ip}:3080:80/tcp"
      # "${ip}:30443:443/tcp"
      "53:53/udp"
      "53:53/tcp"
      "3080:80/tcp"
      "30443:443/tcp"
    ];

    volumes = [
      "/var/lib/pihole/:/etc/pihole/"
      "/var/lib/dnsmasq.d/:/etc/dnsmasq.d/"
    ];

    environmentFiles = [ "/etc/env/pihole/envfile" ];

    extraOptions = [
      "--cap-add=NET_ADMIN"
      "--cap-add=SYS_TIME"
      "--cap-add=SYS_NICE"
      # "--dns=127.0.0.1"
      "--dns=9.9.9.9"
    ];
  };

  system.activationScripts.makePiholeDirs = lib.stringAfter [ "var" ] ''
    mkdir -p /var/lib/pihole
    mkdir -p /var/lib/dnsmasq.d
  '';

  networking.firewall.allowedTCPPorts = [ 53 3080 30443 ];
  networking.firewall.allowedUDPPorts = [ 53 ];

  # Create local records to point to the server directly
  # to bypass Cloudflare proxies
  # system.activationScripts.copyLocalRecords = ''
  #   cp ${pkgs.writeText "custom.conf" localRecords } /var/lib/dnsmasq.d/custom.conf
  #   chown root:root /var/lib/dnsmasq.d/custom.conf
  #   chmod 644 /var/lib/dnsmasq.d/custom.conf
  # '';
}

