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
      PasswordAuthentication = true;
      AllowUsers = [ "${username}" ]; # Allows all users by default. Can be [ "luka" "root" ]
      UseDns = true;
      X11Forwarding = false;
      PermitRootLogin = "no";
    };
  };

  users.users.${username}.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDayyvXEw2BlfSSghaLTKFkI/jbmWJZma8D3TAz3IIKc0tyeRzjsjTNOu7ANW3ZdkvIHMEeGCwfdwjKAojFOmatqKuPCY0vjmyNOxJ2HucCoCt+/r9LwJG0JdS+wFNtV07hRuJ12h8Y4BHHT/F7BKnmKM+BXmlUDj5gEPPcLaKMfWEBHPIjYFj71o0KRNlzFngD1S59MfYkbC2Uo9B1lnAgWzr1+RAXp+4VKSnrdGwkNfXZ1XsT4jKPBWyxS5AWVP5seVt9MlMxEewCMV0Nac3oHjjdNfuNAqkn1OF3/mZntDxAMEEGnsNqvAlwl/3Eejao7+KoBScicnshWhfltUBNu2TLwOMQ+dOiLPpjt2k6mcgUXkG8f2qTfSxgUtW2Gojz60AED2DUlMnm9jLJk1foTsGtLA8nWossl3vA2vHBR7Z1tM+mB+qeP3roZ62J+J1nhllxFWwR9G2WtD+bGZbJ+j0zSopC5OtOK2KunnIv14m+wXE6fN8uRDcz6iL65Ms= lukad"
  ];

  # Open ports in the firewall:
  #
  # 6968  TCP     - SSH
  # 53    TCP/UDP - DNS queries to Blocky
  # 39999     UDP - WireGuard VPN
  # 443   TCP     - nginx
  # 80    TCP     - nginx
  # 25565 TCP     - Minecraft
  networking.firewall = {
    enable = true;

    allowedTCPPorts = [ 53 6968 80 443 39999 ];
    allowedUDPPorts = [ 53 39999 ];
  };
}
