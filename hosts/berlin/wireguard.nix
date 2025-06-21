{ config, pkgs, ... }:

let
  interfaceName = "br0";
in
{
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1; # Enable IP forwarding

  networking.wg-quick.interfaces.wg0 = {
    address = [ "10.20.20.10/24" ];
    listenPort = 6968;
    privateKeyFile = "/etc/env/wireguard/private";

    postUp = ''
      ${pkgs.iptables}/bin/iptables -A FORWARD -i wg0 -j ACCEPT
      ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.20.20.0/24 -o ${interfaceName} -j MASQUERADE
    '';
    preDown = ''
      ${pkgs.iptables}/bin/iptables -D FORWARD -i wg0 -j ACCEPT
      ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.20.20.0/24 -o ${interfaceName} -j MASQUERADE
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

  networking.firewall.allowedUDPPorts = [ 6968 ];
}

