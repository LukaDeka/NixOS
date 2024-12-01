{ pkgs, config, ... }:

let
  username = config.vars.username;
  hostname = config.vars.hostname;
in
{
  services.openssh = {
    enable = true;
    ports = [ 6968 ];
    settings = {
      PasswordAuthentication = false;
      AllowUsers = [ "${username}" ]; # Only allow your user to login
      UseDns = true;
      X11Forwarding = false;
      PermitRootLogin = "no";
    };
  };

  services.fail2ban = {
    enable = true;
    bantime = "24h"; # Ban IPs for one day on the first ban
  };

  # Open ports in the firewall:
  #
  # 6968  TCP     - SSH
  # 53    TCP/UDP - DNS queries to Pihole
  # 39999     UDP - WireGuard VPN
  # 443   TCP     - nginx
  # 80    TCP     - nginx
  # 25565 TCP     - Minecraft server
  networking.firewall = {
    enable = true;

    allowedTCPPorts = [ 53 80 443 39999 ];
    allowedUDPPorts = [ 53 39999 ];
  };
}
