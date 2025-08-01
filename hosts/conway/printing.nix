{ config, pkgs, inputs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  hardware.printers = {
    ensurePrinters = [ {
      name = "M2026";
      location = "Home";
      deviceUri = "usb://Samsung/M2020%20Series?serial=08HVB8GH8A00BQW";
      model = "Samsung_M2020_Series.ppd";
      ppdOptions = {
        PageSize = "A4";
      };
    } ];
    ensureDefaultPrinter = "M2026";
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    publish = {
      enable = true;
      userServices = true;
    };
  };
  services.printing = {
    enable = true;
    # logLevel = "debug";
    drivers = [
      pkgs.samsung-unified-linux-driver
      (pkgs.writeTextDir "share/cups/model/Samsung_M2020_Series.ppd"
        (builtins.readFile ../../misc/drivers/Samsung_M2020_Series.ppd))
    ];
    listenAddresses = [ "*:631" ];
    allowFrom = [ "all" ];
    browsing = true;
    defaultShared = true;
    openFirewall = true;
  };

  services.samba = {
    enable = true;
    # package = pkgs.sambaFull;
    package = inputs.nixpkgs-stable.legacyPackages.${pkgs.system}.sambaFull;
    openFirewall = true;
    settings = {
      global = {
        "load printers" = "yes";
        "printing" = "cups";
        "printcap name" = "cups";
        "printers" = ''
          "comment" = "All Printers";
          "path" = "/var/spool/samba";
          "public" = "yes";
          "browseable" = "yes";
          # to allow user 'guest account' to print.
          "guest ok" = "yes";
          "writable" = "no";
          "printable" = "yes";
          "create mode" = 0700;
        '';
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/spool/samba 1777 root root -"
  ];
}

