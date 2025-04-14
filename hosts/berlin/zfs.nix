{ config, pkgs, ... }:

{
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;

  # Set the name of the pool to import it on boot
  boot.zfs.extraPools = [ "zfs0" ];

  # The unique 32-bit ID of the machine. Used for making sure
  # a ZFS pool isn't accidentally imported on a wrong machine.
  # Generate it using: $ head -c 8 /etc/machine-id
  networking.hostId = "462929b0";

  # Defaults to once a week
  services.zfs = {
    autoSnapshot = {
      enable = true;
      flags = "-k -p --utc";
    };

    autoScrub.enable = true;
  };
}

