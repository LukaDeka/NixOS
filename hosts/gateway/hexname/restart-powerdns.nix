{ pkgs, ... }:

{
  systemd.timers.restart-powerdns = {
    timerConfig = {
      Unit = "update-containers.service";
      OnCalendar = "Sat 10:52"; # 10 mins after podman pull
    };
    wantedBy = [ "timers.target" ];
  };
  systemd.services.restart-powerdns = {
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.systemd}/bin/systemctl try-restart podman-powerdns.service";
    };
  };
}


