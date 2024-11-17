{ config, pkgs, ... }:

let
  scriptPath = "${config.vars.homeDir}/nixos/scripts";
  execAfter = [ "network.target" ]; # Ensure network is up
in
{
  systemd.services = {
    "duckdns" = {
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
    "cf-ddns-updater" = {
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
    "duckdns" = {
      wantedBy = [ "timers.target" ];
      partOf = [ "duckdns.service" ];
      timerConfig = {
        Persistent = true; # Execute immediately if missed
        OnUnitActiveSec = "30m"; # Run every x minutes
        Unit = "duckdns.service";
      };
    };
    "cf-ddns-updater" = {
      wantedBy = [ "timers.target" ];
      partOf = [ "cf-ddns-updater.service" ];
      timerConfig = {
        Persistent = true;
        OnUnitActiveSec = "30m";
        Unit = "cf-ddns-updater.service";
      };
    };
  };
}
