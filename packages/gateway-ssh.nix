{ pkgs, config, ... }:

let
  username = config.vars.username;
  hostname = config.vars.hostname;
in
{
  services.openssh = {
    enable = true;
    ports = [ 6868 ];
    settings = {
      PasswordAuthentication = false;
      AllowUsers = [ "${username}" "root" ];
      UseDns = false; # Disable checking of rDNS records to speed up login
      X11Forwarding = false;
      PermitRootLogin = "prohibit-password";
    };
  };

  services.fail2ban = {
    enable = true;
    bantime = "24h"; # Ban IPs for one day on the first ban
    ignoreIP = [ "143.58.100.0/24" ];
  };

  # Open ports in the firewall:
  #
  # 53    TCP/UDP - DNS queries to Pihole
  # 80    TCP     - nginx
  # 443   TCP     - nginx
  # 6968  TCP     - SSH
  # 25565 TCP     - Minecraft server
  # 39999     UDP - WireGuard VPN
  networking.firewall = {
    enable = true;

    # allowedTCPPorts = [];
    # allowedUDPPorts = [];
  };
}

