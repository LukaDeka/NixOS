{ config, pkgs, ... }:

{
  systemd = {
    services = {
      "duckdns" = {
        after = [ "network.target" "blocky.service" ]; # Ensure network is up
        wantedBy = [ "multi-user.target" ];
        serviceConfig.Type = "simple";
        path = with pkgs; [ bash curl ];
        script = ''
          bash /home/luka/nixos/scripts/duckdns/duck.sh
        '';
      };
      "cloudflare-lukadeka" = {
        after = [ "network.target" "blocky.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig.Type = "simple";
        path = with pkgs; [ bash curl ];
        script = ''
          bash /home/luka/nixos/scripts/cloudflare/lukadeka.sh
        '';
      };
      "cloudflare-seafile.lukadeka" = {
        after = [ "network.target" "blocky.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig.Type = "simple";
        path = with pkgs; [ bash curl ];
        script = ''
          bash /home/luka/nixos/scripts/cloudflare/seafile.lukadeka.sh
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
      "cloudflare-lukadeka" = {
        wantedBy = [ "timers.target" ];
        timerConfig.Persistent = true;
        timerConfig.OnUnitActiveSec = "30m";
        timerConfig.Unit = "cloudflare-lukadeka.service";
      };
      "cloudflare-seafile.lukadeka" = {
        wantedBy = [ "timers.target" ];
        timerConfig.Persistent = true;
        timerConfig.OnUnitActiveSec = "30m";
        timerConfig.Unit = "cloudflare-seafile.lukadeka.service";
      };
    };
  };
}
