{ config, pkgs, ... }:

{
  services.blocky = {
    enable = true;
    settings = {
      ports.dns = 53; # Port for incoming DNS queries
      upstreams.groups.default = [
        "https://one.one.one.one/dns-query" # Using Cloudflare's DNS over HTTPS server for resolving queries
      ];
      
      # For initially solving DoH/DoT Requests when no system Resolver is available
      bootstrapDns = {
        upstream = "https://one.one.one.one/dns-query";
        ips = [ "1.1.1.1" "1.0.0.1" ];
      };

      # Enable Blocking of unwanted domains
      blocking = {
        blackLists = {
          ads = [ "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts" ];
        };

        # Configure what block categories are used
        clientGroupsBlock = {
          default = [ "ads" ];
        };
      };

      #log = {
      #  level = "info";
      #  format = "text";
      #  timestamp = true;
      #};
      #queryLog.type = "csv";
      #queryLog.target = "/var/log/blocky.log";
      #queryLog.flushInterval = "1s";

      # Add a cache of DNS requests and prefetching
      caching = {
        minTime = "5m";
        maxTime = "30m";
        prefetching = true;
      };
    };
  };
}

