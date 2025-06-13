{ pkgs, config, ... }:

let
  username = config.vars.username;
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

  networking.firewall = {
    enable = true;

    # allowedTCPPorts = [];
    # allowedUDPPorts = [];
  };
}

