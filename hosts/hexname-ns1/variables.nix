{ pkgs, options, lib, ... }:

{
  options.vars = {
    username = lib.mkOption {
      type = lib.types.str;
      description = "The username for the current host.";
      default = "luka";
    };
  };
}

