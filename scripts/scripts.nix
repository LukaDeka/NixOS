{ config, pkgs, ... }:

let
  homeDir = config.vars.homeDir;
  domain = config.vars.domain;
in
{
  systemd = {
    services = {
      "duckdns" = {
        after = [ "network.target" "blocky.service" ]; # Ensure network is up
        wantedBy = [ "multi-user.target" ];
        serviceConfig.Type = "simple";
        path = with pkgs; [ bash curl ];
        script = ''
          bash ${homeDir}/nixos/scripts/duckdns/duck.sh
        '';
      };
      "cf-${domain}" = {
        after = [ "network.target" "blocky.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig.Type = "simple";
        path = with pkgs; [ bash curl ];
        script = ''
          bash ${homeDir}/nixos/scripts/cloudflare/${domain}.sh
        '';
      };
      "cf-seafile.${domain}lukadeka" = {
        after = [ "network.target" "blocky.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig.Type = "simple";
        path = with pkgs; [ bash curl ];
        script = ''
          bash ${homeDir}/nixos/scripts/cloudflare/seafile.${domain}.sh
        '';
      };
      "cf-nextcloud.${domain}" = {
        after = [ "network.target" "blocky.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig.Type = "simple";
        path = with pkgs; [ bash curl ];
        script = ''
          bash ${homeDir}/nixos/scripts/cloudflare/nextcloud.${domain}.sh
        '';
      };
    };

    timers = {
      "duckdns" = {
        wantedBy = [ "timers.target" ];
        timerConfig.Persistent = true; # Execute immediately if missed
        timerConfig.OnUnitActiveSec = "30m"; # Run every x minutes
        timerConfig.Unit = "duckdns-service.service";
      };
      "cf-${domain}" = {
        wantedBy = [ "timers.target" ];
        timerConfig.Persistent = true;
        timerConfig.OnUnitActiveSec = "30m";
        timerConfig.Unit = "cf-${domain}.service";
      };
      "cf-seafile.${domain}" = {
        wantedBy = [ "timers.target" ];
        timerConfig.Persistent = true;
        timerConfig.OnUnitActiveSec = "30m";
        timerConfig.Unit = "cf-seafile.${domain}.service";
      };
      "cf-nextcloud.${domain}" = {
        wantedBy = [ "timers.target" ];
        timerConfig.Persistent = true;
        timerConfig.OnUnitActiveSec = "30m";
        timerConfig.Unit = "cf-nextcloud.${domain}.service";
      };
    };
  };
}
