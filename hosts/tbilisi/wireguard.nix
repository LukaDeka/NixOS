{ config, pkgs, ... }:

let
  homeDir = config.vars.homeDir;
in
{
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1; # Enable IP forwarding

  networking.firewall.allowedUDPPorts = [ 39999 ];

  networking.wg-quick.interfaces = {
    # "wg0" is the network interface name. You can name the interface arbitrarily.
    wg0 = {
      # Determines the IP/IPv6 address and subnet of the client's end of the tunnel interface
      address = [ "192.168.255.0/16" ];

      listenPort = 39999;

      privateKeyFile = "/etc/env/wireguard/private";

      # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
      postUp = ''
        ${pkgs.iptables}/bin/iptables -A FORWARD -i wg0 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 192.168.255.0/16 -o wlp3s0 -j MASQUERADE
        ${pkgs.iptables}/bin/ip6tables -A FORWARD -i wg0 -j ACCEPT
        ${pkgs.iptables}/bin/ip6tables -t nat -A POSTROUTING -s fdc9:281f:04d7:9ee9::1/64 -o wlp3s0 -j MASQUERADE
      '';

      # Undo the above
      preDown = ''
        ${pkgs.iptables}/bin/iptables -D FORWARD -i wg0 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 192.168.255.0/16 -o wlp3s0 -j MASQUERADE
        ${pkgs.iptables}/bin/ip6tables -D FORWARD -i wg0 -j ACCEPT
        ${pkgs.iptables}/bin/ip6tables -t nat -D POSTROUTING -s fdc9:281f:04d7:9ee9::1/64 -o wlp3s0 -j MASQUERADE
      '';

      peers = [
        { # LG Gram
          publicKey = "LbEljq4mZKVLdjc0fjoJpmwrvTt3b4L9wFyZSu7MyxA=";
          presharedKeyFile = "/etc/env/wireguard/psk";
          allowedIPs = [ "192.168.255.1/32" ];
        }
        { # Moto G30
          publicKey = "Zbo5s/arjKaKUvJfakGtUIMoLO/+qc/PQA9FSDB01AY=";
          allowedIPs = [ "192.168.255.2/32" ];
        }
      ];
    };
  };
}

