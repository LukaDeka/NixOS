{ config, pkgs, lib, ... }:

{
  networking.firewall.allowedUDPPortRanges = [{ from = 40000; to = 40050; }];
  networking.firewall.allowedUDPPorts = [ 3478 51820 ];

  powerManagement.powertop.enable = true;

  # programs.zsh = {
  #   enable = true;
  #   syntaxHighlighting.enable = true;
  #   autosuggestions.enable = true;
  #   histSize = 50000;
  # };
  # users.defaultUserShell = pkgs.zsh;

  programs.git = {
    enable = true;
    config = {
      user.name = config.vars.username;
      user.email = config.vars.email;
    };
  };

  networking.hostName = config.vars.hostname; # Set the device hostname
  networking.wireless.enable = lib.mkForce false; # Use Wi-Fi via NetworkManager
  networking.networkmanager.enable = true;

  # Rename the network interface
  systemd.network.links = {
    "10-eth0" = {
      matchConfig.PermanentMACAddress = config.vars.ethernetMAC;
      linkConfig.Name = "eth0";
    };
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = let
    locale = "en_US.UTF-8";
  in {
    LC_ADDRESS = locale;
    LC_IDENTIFICATION = locale;
    LC_MEASUREMENT = locale;
    LC_MONETARY = locale;
    LC_NAME = locale;
    LC_NUMERIC = locale;
    LC_PAPER = locale;
    LC_TELEPHONE = locale;
    LC_TIME = locale;
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  nix = {
    settings.experimental-features = [ "nix-command" "flakes" ];
    optimise.automatic = true;

    package = pkgs.nixVersions.latest;

    # Remove warning each rebuild that files aren't commited to git
    extraOptions = ''
      warn-dirty = false
    '';

    gc = {
      automatic = true;
      dates = "Fri *-*-* 04:00:00";
      options = "--delete-older-than 14d";
    };
  };
}

