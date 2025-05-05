{ config, pkgs, ... }:

{
  networking = {
    # Enable a network bridge and route all traffic through it, since
    # the services running on the VMs are inaccessible otherwise.
    # With this setup, each VM gets an IP address through DHCP
    interfaces = {
      br0.useDHCP = true;
      eth0.useDHCP = false;
      wlan0.useDHCP = false; # Disable Wi-Fi, since it interferes with br0
    };
    bridges.br0.interfaces = [ "eth0" ]; # Bind eth0 to the bridge

    firewall = {
      trustedInterfaces = [ "br0" ];
      allowedTCPPorts = [ 8443 ]; # Incus web UI port
    };
    nftables.enable = true; # Required by Incus
  };

  virtualisation.incus.enable = true;
  virtualisation.incus.ui.enable = true;
  virtualisation.incus.preseed = {
    profiles = [ {
      name = "main";
      devices = {
        eth0 = {
          name = "eth0";
          type = "nic";
          network = "br0";
        };
        root = {
          path = "/";
          pool = "default";
          size = "30GiB";
          type = "disk";
        };
      };
    } ];

    storage_pools = [ {
      name = "default";
      driver = "dir";
      config = {
        source = "/var/lib/incus/storage-pools/default";
      };
    } ];
  };
}

