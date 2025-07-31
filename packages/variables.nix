{ lib, config, options, ... }:

{
  options.vars = {

    username = lib.mkOption {
      type = lib.types.str;
      description = "The username for the current host.";
      default = "luka";
    };

    homeDir = lib.mkOption {
      type = lib.types.str;
      description = "The user's home directory. This should only be set if it's in a non-default location.";
      default = "/home/${config.vars.username}";
    };

    hostname = lib.mkOption {
      type = lib.types.str;
      description = "The hostname for the current host.";
      default = null;
    };

    email = lib.mkOption {
      type = lib.types.str;
      description = "The main email address for the current host.";
      default = null;
    };

    domain = lib.mkOption {
      type = lib.types.str;
      description = "The domain name for server programs.";
      example = "coolsite.com";
      default = null;
    };

    ddnsDomain = lib.mkOption {
      type = lib.types.str;
      description = "The DDNS domain name for SSH access etc.";
      example = "coolguy.duckdns.org";
      default = null;
    };

    privateIp = lib.mkOption {
      type = lib.types.str;
      description = "The private IP address of the device.";
      example = "192.168.0.100";
      default = null;
    };

    serverNetbirdIp = lib.mkOption {
      type = lib.types.str;
      description = "The Netbird IP address of the server that's being served by the proxy.";
      example = "100.124.11.22";
      default = null;
    };

    proxyNetbirdIp = lib.mkOption {
      type = lib.types.str;
      description = "The Netbird IP address of the proxy.";
      example = "100.124.11.23";
      default = null;
    };

    ethernetMAC = lib.mkOption {
      type = lib.types.str;
      description = "The MAC address of the main ethernet interface to be renamed.";
      example = "00:B0:D0:63:C2:26";
      default = null;
    };

    storageDir = lib.mkOption {
      type = lib.types.str;
      description = "The path where to store data/databases. Change if you mounted additional drives.";
      example = "/mnt/md0";
      default = "/var/lib";
    };

    startChargeThresh = lib.mkOption {
      type = lib.types.int;
      description = "Start battery charging before dropping below this percentage.";
      default = 40;
    };

    stopChargeThresh = lib.mkOption {
      type = lib.types.int;
      description = "Stop battery charging after reaching this percentage.";
      default = 50;
    };
  };

  config.assertions = [
    {
      assertion = options.vars.username.isDefined;
    }
    {
      assertion = options.vars.hostname.isDefined;
    }
    {
      assertion = options.vars.email.isDefined;
    }
    {
      assertion = options.vars.ethernetMAC.isDefined;
    }
  ];
}
