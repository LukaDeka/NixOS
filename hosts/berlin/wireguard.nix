{ config, pkgs, ... }:

{
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1; # Enable IP forwarding

  networking.firewall.allowedUDPPorts = [ 39999 ];

  networking.wg-quick.interfaces = {
    # "wg0" is the network interface name. You can name the interface arbitrarily.
    wg0 = {
      # Determines the IP/IPv6 address and subnet of the client's end of the tunnel interface
      address = [ "10.20.20.10/24" ];

      listenPort = 39999;

      privateKeyFile = "/etc/env/wireguard/private";

      # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
      postUp = ''
        ${pkgs.iptables}/bin/iptables -A FORWARD -i wg0 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.20.20.0/24 -o br0 -j MASQUERADE
      '';

      # Undo the above
      preDown = ''
        ${pkgs.iptables}/bin/iptables -D FORWARD -i wg0 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.20.20.0/24 -o br0 -j MASQUERADE
      '';

      peers = [
        { # LG Gram
          publicKey = "sSi8ZrKc99rlqdXJY6iuQC1QyXe+dKJOHZdq4CL4H0k=";
          presharedKeyFile = "/etc/env/wireguard/psk";
          allowedIPs = [ "10.20.20.20/32" ];
        }
        { # S
          publicKey = "vBlpzpyMa170OQL97Zj0bWCJwV0azpSGBnPVUIsJy1Y=";
          allowedIPs = [ "10.20.20.30/32" ];
        }
      ];
    };
  };
}

