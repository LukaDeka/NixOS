{ config, pkgs, ... }:

let
  storageDir = config.vars.storageDir;
in
{
  services.deluge = {
    enable = true;
    declarative = true;

    # dataDir = "${storageDir}/deluge";
    authFile = "/etc/env/deluge/authfile";

    config = {
      download_location = "${storageDir}/downloads/deluge";
      max_download_speed = 50000; # In KiB
      max_upload_speed = 1000;
      share_ratio_limit = 2.0;
      allow_remote = true;
      daemon_port = 58846;
      listen_ports = [ 6881 6889 ];
    };

    web = {
      enable = true;
      openFirewall = true;
      port = 8112;
    };
  };
}

