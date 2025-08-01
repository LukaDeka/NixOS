{ config, ... }:

let
  storageDir = config.vars.storageDir;
  serverNetbirdIp = config.vars.serverNetbirdIp;
in
{
  services.restic.server = {
    enable = true;
    dataDir = "${storageDir}/restic";
    listenAddress = "${serverNetbirdIp}:43091";
    htpasswd-file = "/etc/env/restic/htpasswd"; # username:hashedpassword
  };
}

