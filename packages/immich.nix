{ config, ... }:

{
  services.immich = {
    enable = true;
    openFirewall = true;
    port = 2283;
    host = "0.0.0.0";

    mediaLocation = "${config.vars.storageDir}/immich";

    # `null` gives access to all devices.
    accelerationDevices = null;
  };
}

