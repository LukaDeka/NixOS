{ config, pkgs, ... }:

let
  scriptPath = "${config.vars.homeDir}/nixos/scripts";
  execAfter = [ "network.target" ]; # Ensure network is up
  envVars = {
    VAR_DDNS = config.vars.ddnsDomain;
    VAR_HOME_DIR = config.vars.homeDir;
  };
in
{
  systemd.services = {
    "duckdns" = {
      environment = envVars;
      after = execAfter;
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
      path = with pkgs; [ bash curl ];
      script = ''
        bash ${scriptPath}/duckdns/duck.sh
      '';
    };
  };

  systemd.timers = {
    "duckdns" = {
      wantedBy = [ "timers.target" ];
      partOf = [ "duckdns.service" ];
      timerConfig = {
        Persistent = true; # Execute immediately if missed
        OnUnitActiveSec = "30m"; # Run every x minutes
        Unit = "duckdns.service";
      };
    };
  };
}

