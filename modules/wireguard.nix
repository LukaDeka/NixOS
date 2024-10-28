{ config, pkgs, ... }:

{
  # Enable IP forwarding
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  networking.wg-quick.interfaces = {
    # "wg0" is the network interface name. You can name the interface arbitrarily.
    wg0 = {
      # Determines the IP/IPv6 address and subnet of the client's end of the tunnel interface
      address = [ "10.20.30.1/24" ];

      # The port that WireGuard listens to - recommended that this be changed from default
      listenPort = 39999;

      # Path to the server's private key
      privateKeyFile = "/home/luka/env/wireguard/private";

      # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
      postUp = ''
        ${pkgs.iptables}/bin/iptables -A FORWARD -i wg0 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.20.30.1/24 -o eth0 -j MASQUERADE
        ${pkgs.iptables}/bin/ip6tables -A FORWARD -i wg0 -j ACCEPT
        ${pkgs.iptables}/bin/ip6tables -t nat -A POSTROUTING -s fdc9:281f:04d7:9ee9::1/64 -o eth0 -j MASQUERADE
      '';

      # Undo the above
      preDown = ''
        ${pkgs.iptables}/bin/iptables -D FORWARD -i wg0 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.20.30.1/24 -o eth0 -j MASQUERADE
        ${pkgs.iptables}/bin/ip6tables -D FORWARD -i wg0 -j ACCEPT
        ${pkgs.iptables}/bin/ip6tables -t nat -D POSTROUTING -s fdc9:281f:04d7:9ee9::1/64 -o eth0 -j MASQUERADE
      '';

      peers = [
        { # LG Gram
          publicKey = "ru0iGynezM5INvTDk1LmRb3v4+NSIuBFc7CvCj3O1no=";
          presharedKeyFile = "/home/luka/env/wireguard/psk";
          allowedIPs = [ "10.20.30.2/32" ];
        }
        { # Moto G30
          publicKey = "vBlpzpyMa170OQL97Zj0bWCJwV0azpSGBnPVUIsJy1Y=";
          allowedIPs = [ "10.20.30.3/32" ];
        }
      ];
    };
  };
}

