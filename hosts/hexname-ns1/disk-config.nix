{ config, ... }:

{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              name = "boot";
              size = "1M";
              type = "EF02";
            };
            ESP = {
              name = "ESP";
              size = "2G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            swap = {
              size = "4G";
              content = {
                type = "swap";
                randomEncryption = true;
              };
            };
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
          };
        };
      };
    };
    zpool = {
      zroot = {
        type = "zpool";

        rootFsOptions = {
          compression = "zstd";
          acltype = "posixacl";
          xattr = "sa";
          dnodesize = "auto";
          "com.sun:auto-snapshot" = "false";
        };

        datasets = {
          nixos = {
            type = "zfs_fs";
            mountpoint = "/";
          };
          "nixos/var" = {
            type = "zfs_fs";
            mountpoint = "/var";
          };
          "nixos/var/lib" = {
            type = "zfs_fs";
            mountpoint = "/var/lib";
            options."com.sun:auto-snapshot" = "true";
          };
          "nixos/var/log" = {
            type = "zfs_fs";
            mountpoint = "/var/log";
            options."com.sun:auto-snapshot" = "true";
          };
          "nixos/nix" = {
            type = "zfs_fs";
            mountpoint = "/nix";
          };
          "nixos/etc/nixos" = {
            type = "zfs_fs";
            mountpoint = "/etc/nixos";
            options."com.sun:auto-snapshot" = "true";
          };
          "nixos/home" = {
            type = "zfs_fs";
            mountpoint = "/home";
            options."com.sun:auto-snapshot" = "true";
          };
        };
      };
    };
  };
}

