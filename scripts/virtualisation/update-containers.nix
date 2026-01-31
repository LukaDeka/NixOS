{ pkgs, lib, ... }:

{
  systemd.timers.update-containers = {
    timerConfig = {
      Unit = "update-containers.service";
      OnCalendar = "Sat 10:42";
    };
    wantedBy = [ "timers.target" ];
  };
  systemd.services.update-containers = {
    serviceConfig = {
      Type = "oneshot";
      ExecStart = lib.getExe (pkgs.writeShellScriptBin "update-containers" ''
        images=$(${pkgs.podman}/bin/podman ps -a --format="{{.Image}}" | sort -u)

        for image in $images; do
          ${pkgs.podman}/bin/podman pull "$image"
        done
      '');
    };
  };
}

