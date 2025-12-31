{ config, pkgs, inputs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  hardware.printers = {
    ensurePrinters = [ {
      name = "HP-LaserJet-P1005";
      location = "Home";
      deviceUri = "usb://HP/LaserJet%20P1005?serial=BC1ET15";
      model = "HP/hp-laserjet_p1005.ppd.gz";
      ppdOptions = {
        PageSize = "A4";
      };
    } ];
    ensureDefaultPrinter = "HP-LaserJet-P1005";
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
      pkgs.hplipWithPlugin
    ];
    listenAddresses = [ "*:631" ];
    allowFrom = [ "all" ];
    browsing = true;
    defaultShared = true;
    openFirewall = true;
  };

  services.samba = {
    enable = true;
    # package = inputs.nixpkgs-stable.legacyPackages.${pkgs.system}.sambaFull;
    package = pkgs.sambaFull;
    openFirewall = true;
    settings = {
      global = {
        "server min protocol" = "NT1";
        "load printers" = "yes";
        "printing" = "cups";
        "printcap name" = "cups";
      };
      "printers" = {
        "comment" = "All Printers";
        "path" = "/var/spool/samba";
        "public" = "yes";
        "browseable" = "yes";
        # to allow user 'guest account' to print.
        "guest ok" = "yes";
        "writable" = "no";
        "printable" = "yes";
        "create mode" = 0700;
      };
    };
  };
    # settings = {
    #   global = {
    #     "load printers" = "yes";
    #     "printing" = "cups";
    #     "printcap name" = "cups";
    #     "printers" = ''
    #       "comment" = "All Printers";
    #       "path" = "/var/spool/samba";
    #       "public" = "yes";
    #       "browseable" = "yes";
    #       # to allow user 'guest account' to print.
    #       "guest ok" = "yes";
    #       "writable" = "no";
    #       "printable" = "yes";
    #       "create mode" = 0700;
    #     '';
    #   };
    # };

  systemd.tmpfiles.rules = [
    "d /var/spool/samba 1777 root root -"
  ];

  networking.firewall.extraCommands = ''iptables -t raw -A OUTPUT -p udp -m udp --dport 137 -j CT --helper netbios-ns'';
}

