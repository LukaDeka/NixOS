{ config, pkgs, ... }:

let
  scriptPath = "${config.vars.homeDir}/nixos/scripts";
  after = [ "network.target" "NetworkManager.service" "uptime-kuma.service" ];
  environment = {
    VAR_IP = config.vars.privateIp;
  };
in
{
  systemd.services = {
    "zfs-uptime-kuma" = {
      inherit environment after;
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
      path = with pkgs; [ bash curl zfs jq ];
      script = ''
        bash ${scriptPath}/zfs-healthcheck/uptime-kuma.sh
      '';
    };
  };

  systemd.timers = {
   "zfs-uptime-kuma" = {
      wantedBy = [ "timers.target" ];
      partOf = [ "zfs-uptime-kuma.service" ];
      timerConfig = {
        Persistent = true; # Execute immediately if missed
        OnUnitActiveSec = "7m"; # Run every x minutes
        Unit = "zfs-uptime-kuma.service";
      };
    };
  };
}

