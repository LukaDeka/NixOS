{ config, pkgs, ... }:

let
  ip = config.vars.ip;
  domain = config.vars.domain;

  localRecords = ''
    address=/${domain}/${ip}
    address=/nextcloud.${domain}/${ip}
    address=/jellyfin.${domain}/${ip}
    address=/ddns.${domain}/${ip}
  '';
in
{
  virtualisation.oci-containers.containers.pihole = {
    image = "pihole/pihole:latest";
    ports = [
      "0.0.0.0:53:53/tcp" # Accept DNS queries from all IPs TODO: Restrict to local network
      "0.0.0.0:53:53/udp"
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

  networking.firewall.allowedTCPPorts = [ 53 ];
  networking.firewall.allowedUDPPorts = [ 53 ];

  # Create local records to point to the server directly
  # to bypass Cloudflare proxies
  system.activationScripts.copyLocalRecords = ''
    cp ${pkgs.writeText "custom.conf" localRecords } /var/lib/dnsmasq.d/custom.conf
    chown root:root /var/lib/dnsmasq.d/custom.conf
    chmod 644 /var/lib/dnsmasq.d/custom.conf
  '';
}

