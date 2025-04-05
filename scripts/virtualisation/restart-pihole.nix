{ pkgs, ... }:

{
  systemd.timers.restart-pihole = {
    timerConfig = {
      Unit = "update-containers.service";
      OnCalendar = "Tue 02:40"; # 10 mins after podman pull
    };
    wantedBy = [ "timers.target" ];
  };
  systemd.services.restart-pihole = {
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.systemd}/bin/systemctl try-restart podman-pihole.service";
    };
  };
}

