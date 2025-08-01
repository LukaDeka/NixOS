{ config, pkgs, ... }:

let
  username = config.vars.username;
in
{
  virtualisation.oci-containers.containers.craftycontroller = {
    image = "registry.gitlab.com/crafty-controller/crafty-4:latest";
    ports = [
      "5090:8443/tcp" # Admin interface
      "25565:25565"
    ];

    # User credentials for the admin interface are stored in
    # config/default-creds.txt
    volumes = [ # Make sure these directories exist beforehand
      "/home/${username}/mc/backups:/crafty/backups"
      "/home/${username}/mc/logs:/crafty/logs"
      "/home/${username}/mc/servers:/crafty/servers"
      "/home/${username}/mc/config:/crafty/app/config"
      "/home/${username}/mc/import:/crafty/import"
    ];

    environment = {
      TZ = "Europe/Berlin";
    };
  };

  networking.firewall.allowedTCPPorts = [ 5090 25565 ];
  networking.firewall.allowedUDPPorts = [ 25565 ];
}

