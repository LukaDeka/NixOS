{ pkgs, config, ... }:

let
  username = config.vars.username;
in
{
  services.openssh = {
    enable = true;
    ports = [ 6968 ];
    settings = {
      PasswordAuthentication = false;
      AllowUsers = [ "${username}" "root" "forgejo" ];
      UseDns = false; # Disable checking of rDNS records to speed up login
      X11Forwarding = false;
      PermitRootLogin = "prohibit-password";
    };
  };

  services.fail2ban = {
    enable = true;
    bantime = "24h"; # Ban IPs for one day on the first ban
    ignoreIP = [ "100.124.0.0/16" "10.10.0.0/16" ];
  };

  networking.firewall = {
    enable = true;

    # allowedTCPPorts = [];
    # allowedUDPPorts = [];
  };
}

