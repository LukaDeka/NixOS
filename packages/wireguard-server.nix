{ pkgs, ... }:

{
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1; # Enable IP forwarding

  networking.wg-quick.interfaces.wg0 = {
    address = [ "10.20.20.1/24" ];

    listenPort = 39999;

    privateKeyFile = "/etc/env/wireguard/private";

    # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
    # postUp = ''
    #   ${pkgs.iptables}/bin/iptables -A FORWARD -i wg0 -j ACCEPT
    #   ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.20.20.1/24 -o eth0 -j MASQUERADE
    # '';

    # Undo the above
    # preDown = ''
    #   ${pkgs.iptables}/bin/iptables -D FORWARD -i wg0 -j ACCEPT
    #   ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.20.20.1/24 -o eth0 -j MASQUERADE
    # '';

    postUp = ''
      ${pkgs.iptables}/bin/iptables -A FORWARD -i wg0 -o enp1s0 -j ACCEPT
      ${pkgs.iptables}/bin/iptables -A FORWARD -i enp1s0 -o wg0 -m state --state ESTABLISHED,RELATED -j ACCEPT
      ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -o wg0 -j MASQUERADE
    '';

    preDown = ''
      ${pkgs.iptables}/bin/iptables -D FORWARD -i wg0 -o enp1s0 -j ACCEPT
      ${pkgs.iptables}/bin/iptables -D FORWARD -i enp1s0 -o wg0 -m state --state ESTABLISHED,RELATED -j ACCEPT
      ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -o wg0 -j MASQUERADE
    '';



    peers = [
      { # LG Gram
        publicKey = "MG2yr7fa653r0VESdXYax5LUdia6gRVFTpjSmLoQ4no=";
        presharedKeyFile = "/etc/env/wireguard/psk";
        allowedIPs = [ "10.20.20.10/32" ];
      }
      { # S
        publicKey = "vBlpzpyMa170OQL97Zj0bWCJwV0azpSGBnPVUIsJy1Y=";
        allowedIPs = [ "10.20.20.30/32" ];
      }
    ];
  };

  networking.nat = {
    enable = true;
    externalIP = "91.99.69.65";
    externalInterface = "enp1s0";
    internalInterfaces = [ "wg0" ];

    forwardPorts = [
      {
        sourcePort = 6968; # Exposed on VPS
        destination = "10.20.20.10:6968"; # SSH on home
        proto = "tcp";
      }
      {
        sourcePort = 80;
        destination = "10.20.20.10:80";
        proto = "tcp";
      }
      {
        sourcePort = 443;
        destination = "10.20.20.10:443";
        proto = "tcp";
      }
      {
        sourcePort = 39999;
        destination = "10.20.20.10:39999";
        proto = "udp";
      }
      {
        sourcePort = 39999;
        destination = "10.20.20.10:39999";
        proto = "tcp";
      }
    ];
  };

  networking.firewall.allowedTCPPorts = [ 80 443 6968 39999 ]; # REMOVE LAST
  networking.firewall.allowedUDPPorts = [ 39999 ];
}

