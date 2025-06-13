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
      AllowUsers = [ "${username}" "root" ];
      UseDns = false; # Disable checking of rDNS records to speed up login
      X11Forwarding = false;
      PermitRootLogin = "prohibit-password";
    };
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

