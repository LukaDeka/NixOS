{ pkgs, config, ... }:

let
  interfaceName = "enp1s0";
  vpsIp = config.vars.ip;
in
{
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1; # Enable IP forwarding

  networking.wg-quick.interfaces.wg0 = {
    address = [ "10.20.20.1/32" ];
    listenPort = 6868;
    privateKeyFile = "/etc/env/wireguard/private";

    postUp = ''
      ${pkgs.iptables}/bin/iptables -A FORWARD -i wg0 -o ${interfaceName} -j ACCEPT
      ${pkgs.iptables}/bin/iptables -A FORWARD -i ${interfaceName} -o wg0 -m state --state ESTABLISHED,RELATED -j ACCEPT
      ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -o wg0 -j MASQUERADE
    '';
    preDown = ''
      ${pkgs.iptables}/bin/iptables -D FORWARD -i wg0 -o ${interfaceName} -j ACCEPT
      ${pkgs.iptables}/bin/iptables -D FORWARD -i ${interfaceName} -o wg0 -m state --state ESTABLISHED,RELATED -j ACCEPT
      ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -o wg0 -j MASQUERADE
    '';

    peers = [{ # berlin
      publicKey = "MG2yr7fa653r0VESdXYax5LUdia6gRVFTpjSmLoQ4no=";
      presharedKeyFile = "/etc/env/wireguard/psk";
      allowedIPs = [ "10.20.20.10/32" ];
    }];
  };

  networking.nat = {
    enable = true;
    externalIP = vpsIp;
    externalInterface = interfaceName;
    internalInterfaces = [ "wg0" ];

    forwardPorts = [
      { # SSH proxied (internet -> gateway -> berlin)
        sourcePort = 6968; # Exposed on VPS
        destination = "10.20.20.10:6968"; # SSH on home
        proto = "tcp";
      }
      { # Wireguard proxied (internet -> hetzner -> berlin)
        sourcePort = 6968;
        destination = "10.20.20.10:6968";
        proto = "udp";
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
    ];
  };

  networking.firewall.allowedTCPPorts = [ 80 443 6968 ];
  networking.firewall.allowedUDPPorts = [ 6868 6968 ];
}

