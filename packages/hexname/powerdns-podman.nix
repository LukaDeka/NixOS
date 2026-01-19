{ config, pkgs, lib, ... }:

let
  domain = "hexname.com";
in
{
  virtualisation.oci-containers.containers = {
    hexname-powerdns-postgres = {
      hostname = "pgsql";
      image = "postgres:18-alpine";
      # ports = [
      #   "127.0.0.1:5432:5432"
      # ];
      volumes = [
        "/etc/localtime:/etc/localtime:ro"
        "pgsql:/var/lib/postgresql/data:Z"
      ];
      networks = [ "hexname-powerdns-net" ];
      environmentFiles = [ "/etc/env/hexname/postgres.env" ]; # POSTGRES_PASSWORD=...
    };

    hexname-powerdns = {
      image = "pschiffe/pdns-pgsql:latest";
      hostname = "ns1.${domain}";
      ports = [
        "127.0.0.2:53:53/tcp" # TODO: remove localhost
        "127.0.0.2:53:53/udp"
        "127.0.0.2:8081:8081/tcp"
      ];
      networks = [ "hexname-powerdns-net" ];

      volumes = [
        "/etc/localtime:/etc/localtime:ro"
      ];

      environmentFiles = [ "/etc/env/hexname/powerdns.env" ];
      environment = {
        PDNS_primary = "yes";
        PDNS_api = "yes";
        #PDNS_webserver = "yes";
        PDNS_webserver_address = "0.0.0.0";
        PDNS_webserver_port = "8081";
        PDNS_local_address = "0.0.0.0:53";
        PDNS_webserver_allow_from = "10.0.0.0/8";
        PDNS_version_string = "anonymous";
        PDNS_default_ttl = "1500";
        # PDNS_allow_axfr_ips = "172.5.0.21";

        # PDNS_gpgsql_password=...
        # PDNS_api_key=...
      };
      dependsOn = [ "hexname-powerdns-postgres" ];
    };
  };

  systemd.services.podman-network-hexname = {
    description = "Podman network for HexName/PowerDNS";
    after = [ "podman.service" ];
    wantedBy = [ "multi-user.target" "podman-hexname-powerdns.target" "podman-hexname-powerdns-postgres.target" ];
    serviceConfig.Type = "oneshot";
    path = [ pkgs.podman] ;
    script = ''
      podman network inspect hexname-powerdns-net >/dev/null 2>&1 || \
        podman network create hexname-powerdns-net
    '';
  };

  networking.firewall.allowedTCPPorts = [ 53 ];
  networking.firewall.allowedUDPPorts = [ 53 ];
}

