{ config, pkgs, ... }:

{
  services.jellyfin = {
    enable = true;
    openFirewall = true;
    user = config.vars.username;
    # dataDir = "${config.vars.storageDir}/jellyfin";
  };
}

