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

    #strippedDomain = let
    #  parts = builtins.splitString "." config.vars.domain;
    #in if builtins.length parts > 1 then builtins.elemAt parts 0 else config.domain;

    ddnsDomain = lib.mkOption {
      type = lib.types.str;
      description = "The DDNS domain name for SSH access etc.";
      example = "coolguy.duckdns.org";
      default = null;
    };

    ip = lib.mkOption {
      type = lib.types.str;
      description = "The static IP address of the device.";
      example = "192.168.0.100";
      default = null;
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

    # printerDriver = lib.mkOption {
    #   type = lib.types.str;
    #   description = "Optional, the relative path to the printer driver from ./";
    #   example = "etc/drivers/Samsung_M2020_Series.ppd";
    #   default = null;
    # };
  };


  config.assertions = [
    {
      assertion = options.vars.hostname.isDefined;
    }
    {
      assertion = options.vars.email.isDefined;
    }
    {
      assertion = options.vars.ddnsDomain.isDefined;
    }
    {
      assertion = options.vars.ip.isDefined;
    }
  ];
}
