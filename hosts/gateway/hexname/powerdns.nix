{ ... }:

{
  virtualisation.oci-containers.containers = {
    hexname-powerdns = {
      image = "pschiffe/pdns-pgsql:latest";
      hostname = "ns2.hexname.com";

      volumes = [
        "/etc/localtime:/etc/localtime:ro"
      ];

      environmentFiles = [ "/etc/env/hexname/powerdns.env" ];
      environment = {
        PDNS_disable_axfr = "yes";
        PDNS_local_address = "0.0.0.0:53";
        PDNS_version_string = "anonymous";
        PDNS_default_ttl = "3600";

        PDNS_gpgsql_host = "127.0.0.1";
        PDNS_gpgsql_port = "5432";
        PDNS_gpgsql_dbname = "powerdns";
        PDNS_gpgsql_user = "powerdns";
        PDNS_gpgsql_dnssec = "yes";
      };

      extraOptions = [
        "--network=host"
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [ 53 ];
  networking.firewall.allowedUDPPorts = [ 53 ];
}

