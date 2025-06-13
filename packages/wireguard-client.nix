{ pkgs, ... }:

{
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1; # Enable IP forwarding

  networking.wg-quick.interfaces.wg0 = {
    address = [ "10.20.20.10/24" ];

    privateKeyFile = "/etc/env/wireguard/private";

    peers = [
      { # VPS
        publicKey = "cuoZp057Z4zdcW4V7p2jO8iRA1MmKsgiYMC/SCxvW1E=";
        presharedKeyFile = "/etc/env/wireguard/psk";
        allowedIPs = [ "10.20.20.1/32" ];
        endpoint = "91.99.69.65:39999";
        persistentKeepalive = 25;
      }
    ];

  networking.firewall.allowedUDPPorts = [ 39999 ];
  networking.firewall.allowedTCPPorts = [ 39999 ]; # REMOVE THIS

  };
}

