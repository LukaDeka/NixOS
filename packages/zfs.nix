{ config, pkgs, ... }:

{
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  networking.hostId = "462929b0";

  # To import the pool on boot
  boot.zfs.extraPools = [ "zfs0" ];
}

