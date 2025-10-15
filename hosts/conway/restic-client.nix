{ config, ... }:

let
  user = config.vars.username;
  homeDir = config.vars.homeDir;
  # destNetbirdIp = "100.124.170.101";
  dest = "tbilisi";
in
{
  services.restic.backups = {
    regular-backup = {
      paths = [
        "/var/lib"
        "/etc/env"
        "/ssd/nextcloud"
        "/home/luka"
      ];
      exclude = [
        "/home/luka/.bitmonero"
        "/var/lib/lxcfs" # https://forum.restic.net/t/error-message-when-backup-up/6191/11
      ];
      repository = "sftp:${user}@${dest}:/backups/conway";
      extraOptions = [
        "sftp.command='ssh -p 6968 ${user}@${dest} -i ${homeDir}/.ssh/id_ed25519 -s sftp'"
      ];
      passwordFile = "/etc/env/restic/tbilisi-password";
      initialize = true;

      timerConfig = {
        OnCalendar = "01:30";
        Persistent = true;
        RandomizedDelaySec = "30m";
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

