{ config, pkgs, ... }:

{
  virtualisation.docker.enable = true;

  users.users.${config.vars.username}.extraGroups = [ "docker" ];

  # "It is extremely likely that you want to turn off the userland-proxy, which is designed for Windoze"
  virtualisation.docker.daemon.settings = {
    userland-proxy = false;
    experimental = true;
    metrics-addr = "0.0.0.0:9323";
    ipv6 = true;
    fixed-cidr-v6 = "fd00::/80";
  };
}
