{ config, pkgs, ... }:

{
  networking.interfaces.br0.useDHCP = true;
  networking.interfaces.eth0.useDHCP = false;
  # networking.interfaces.wlan0.useDHCP = true;

  networking.firewall.trustedInterfaces = [ "br0" ];
  networking.bridges.br0 = {
    interfaces = [ "eth0" ];
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

  networking.nftables.enable = true;

  networking.firewall.allowedTCPPorts = [ 8443 ];
  networking.firewall.allowedUDPPorts = [ 8443 ];
}

