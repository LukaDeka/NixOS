{ config, pkgs, inputs, ... } @ args:

let
  unstable = inputs.unstable.legacyPackages.${pkgs.system};
in
{
  imports = [ "${args.inputs.unstable}/nixos/modules/services/networking/seafile.nix" ];

  services.seafile = {
    enable = true;
    seahubPackage = unstable.seahub;

    adminEmail = "luka.dekanozishvili1@gmail.com";
    initialAdminPassword = "gamosacdeliparoli";

    seahubAddress = "127.0.0.1:39998";
    ccnetSettings.General.SERVICE_URL = "https://seafile.lukadeka.com";
    seahubExtraConf = ''
      # SERVICE_URL = 'https://seafile.lukadeka.com'
      FILE_SERVER_ROOT = 'https://seafile.lukadeka.com/seafhttp'
      ALLOWED_HOSTS = ['seafile.lukadeka.com','10.10.10.10','10.10.10.10:39998']
      CSRF_TRUSTED_ORIGINS = ['https://seafile.lukadeka.com','10.10.10.10','10.10.10.10:39998']

      ENABLE_ENCRYPTED_LIBRARY = True

      # Enable cloude mode and hide `Organization` tab.
      CLOUD_MODE = True

      # Disable global address book
      ENABLE_GLOBAL_ADDRESSBOOK = False
    '';

    # workers = 2; # Default processes is 4

    # dataDir = "/mnt/md0/seafile";

    seafileSettings = {
      fileserver = {
        host = "ipv4:127.0.0.1";
        port = 8082; # TCP port
        use_go_fileserver = true;
        # max_sync_file_count = 1000000;
        # max_upload_size = 50000; # Default is unlimited
      };

      database = {
        type = "mysql";
        host = "127.0.0.1";
        user = "root";
        password = "root";
        db_name = "seafile_db";
        connection_charset = "utf8";
        max_connections = 100;
      };

      quota = {
        # Default user quota in GB, integer only
        default = 50;
      };
    };
  };

#[fileserver]
# default is false
# check_virus_on_web_upload = true;

#[zip]
# The file name encoding of the downloaded zip file.
#windows_encoding = "iso-8859-1";

#[library_trash]
#expire_days = 5;

}
