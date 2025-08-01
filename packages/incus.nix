{ config, pkgs, ... }:

let
  ethernetMAC = config.vars.ethernetMAC;
in
{
  networking = {
    # Enable a network bridge and route all traffic through it since
    # the services running on the VMs are inaccessible otherwise.
    # With this setup, each VM gets an IP address through DHCP from the router.
    interfaces = {
      br0.macAddress = ethernetMAC; # To make sure the MAC never changes
      br0.useDHCP = true; # Make sure you set a static IP in your router
      eth0.useDHCP = false;
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
      name = "default";
      devices = {
        eth0 = {
          name = "eth0";
          type = "nic";
          nictype = "bridged";
          parent = "br0";
        };
        root = {
          path = "/";
          pool = "default";
          size = "100GiB";
          type = "disk";
        };
      };
    } ];

    storage_pools = [ {
      name = "default";
      driver = "zfs";
      config = {
        source = "nvmepool/incus";
      };
    } ];
  };
}

