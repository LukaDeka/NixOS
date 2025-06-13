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
      AllowUsers = [ "${username}" "root" ];
      UseDns = false; # Disable checking of rDNS records to speed up login
      X11Forwarding = false;
      PermitRootLogin = "prohibit-password";
    };
  };

  networking.firewall = {
    enable = true;

    # allowedTCPPorts = [];
    # allowedUDPPorts = [];
  };
}

