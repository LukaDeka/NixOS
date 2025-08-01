{ config, pkgs, ... }:

let
  ip = config.vars.privateIp;
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
      "${ip}:53:53/tcp"
      "${ip}:53:53/udp"
      "${ip}:3080:80/tcp"
      "${ip}:30443:443/tcp"
    ];

    volumes = [
      "/var/lib/pihole/:/etc/pihole/"
      "/var/lib/dnsmasq.d:/etc/dnsmasq.d/"
    ];

    environmentFiles = [ "/etc/env/pihole/envfile" ];

    extraOptions = [
      "--cap-add=NET_ADMIN"
      "--dns=127.0.0.1"
      "--dns=9.9.9.9"
    ];
  };

  networking.firewall.allowedTCPPorts = [ 53 3080 30443 ];
  networking.firewall.allowedUDPPorts = [ 53 ];

  # TODO: Update the way these records are loaded and make it more declarative
  # Create local records to point to the server directly
  # to bypass Cloudflare proxies
  # system.activationScripts.copyLocalRecords = ''
  #   cp ${pkgs.writeText "custom.conf" localRecords } /var/lib/dnsmasq.d/custom.conf
  #   chown root:root /var/lib/dnsmasq.d/custom.conf
  #   chmod 644 /var/lib/dnsmasq.d/custom.conf
  # '';
}

