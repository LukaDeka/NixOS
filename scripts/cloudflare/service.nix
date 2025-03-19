{ config, pkgs, ... }:

let
  scriptPath = "${config.vars.homeDir}/nixos/scripts";
  execAfter = [ "network.target" ]; # Ensure network is up
  envVars = {
    VAR_EMAIL = config.vars.email;
    VAR_DOMAIN = config.vars.domain;
    VAR_HOME_DIR = config.vars.homeDir;
  };
in
{
  systemd.services = {
    "cf-ddns-updater" = {
      environment = envVars;
      after = execAfter;
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
      path = with pkgs; [ bash curl ];
      script = ''
        bash ${scriptPath}/cloudflare/ddns.sh
      '';
    };
  };

  systemd.timers = {
    "cf-ddns-updater" = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        Persistent = true; # Execute immediately if missed
        OnUnitActiveSec = "30m"; # Run every x minutes
        Unit = "duckdns.service";
      };
    };
  };
}

