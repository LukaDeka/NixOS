{ pkgs, ... }:

{
  systemd.timers.restart-netbird-relay = {
    timerConfig = {
      Unit = "update-containers.service";
      OnCalendar = "Tue 02:40"; # 10 mins after podman pull
    };
    wantedBy = [ "timers.target" ];
  };
  systemd.services.restart-netbird-relay = {
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.systemd}/bin/systemctl try-restart podman-netbird-relay.service";
    };
  };
}

