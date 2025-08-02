{ config, ... }:

let
  user = config.vars.username;
  homeDir = config.vars.homeDir;
  destNetbirdIp = "100.124.170.101";
in
{
  services.restic.backups = {
    regular-backup = {
      paths = [
        "/var/lib"
        # "/etc/env"
        # "/zfs/nextcloud"
        # "/zfs/downloads/music"
      ];
      repository = "sftp:${user}@${destNetbirdIp}:/backups/berlin";
      extraOptions = [
        "sftp.command='ssh -p 6968 ${user}@${destNetbirdIp} -i ${homeDir}/.ssh/id_ed25519 -s sftp'"
      ];
      passwordFile = "/etc/env/restic/tbilisi-password";
      initialize = true;

      timerConfig = {
        OnCalendar = "03:20";
        Persistent = true;
        RandomizedDelaySec = "10m";
      };
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 6"
        "--keep-monthly 12"
        "--keep-yearly 10"
      ];
    };
  };
}

