{ config, pkgs, ... }:

{
  services.seafile = {
    enable = true;
    ccnetSettings.General.SERVICE_URL = "https://seafile.lukadeka.com";
    adminEmail = "luka.dekanozishvili1@gmail.com";
    initialAdminPassword = "defaultpassword";

    #seahubAddress = "0.0.0.0:39998";
    seahubExtraConf = ''
      SERVICE_URL = 'https://seafile.lukadeka.com'
      FILE_SERVER_ROOT = 'https://seafile.lukadeka.com/seafhttp'
      CSRF_TRUSTED_ORIGINS = ["https://seafile.lukadeka.com"]
    '';
    workers = 2; # Default processes is 4

    seafileSettings = {
      fileserver = {
        host = "127.0.0.1";
        port = 8082; # TCP port
        use_go_fileserver = true;
        max_sync_file_count = 1000000;
        max_upload_size = 50000; # Default is unlimited
      };

      database = {
        #type = "mariadb";
        host = "127.0.0.1";
        user = "root";
        password = "root";
        db_name = "seafile_db";
        connection_charset = "utf8";
        max_connections = 100;
      };
    };

#      quota = {
#        # Default user quota in GB, integer only
#        default = 50;
#      };
  };

#[fileserver]
# default is false
# check_virus_on_web_upload = true;

#[zip]
# The file name encoding of the downloaded zip file.
#windows_encoding = "iso-8859-1";

#[library_trash]
#expire_days = 5;

  nixpkgs.config.permittedInsecurePackages = [
    "python3.11-django-3.2.25"
  ];
}
