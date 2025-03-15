{ config, pkgs, ... }:

{
  # Keep laptop running with lid closed
  systemd.sleep.extraConfig = ''
    AllowSuspend=no
  '';

    # AllowHibernation=no
    # AllowHybridSleep=no
    # AllowSuspendThenHibernate=no
  # services.logind.lidSwitch = "ignore";
  # services.logind.lidSwitchExternalPower = "ignore";
  # services.logind.lidSwitchDocked = "ignore";

  # Prevents the overheating of Intel CPUs
  services.thermald.enable = true;

  # Enable battery care (charge up to 50% by default)
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 20;

      START_CHARGE_THRESH_BAT0 = config.vars.startChargeThresh;
      STOP_CHARGE_THRESH_BAT0 = config.vars.stopChargeThresh;

      START_CHARGE_THRESH_BAT1 = config.vars.startChargeThresh;
      STOP_CHARGE_THRESH_BAT1 = config.vars.stopChargeThresh;
    };
  };

  programs.git = {
    enable = true;
    config = {
      user.name = config.vars.username;
      user.email = config.vars.email;
    };
  };

  networking.hostName = config.vars.hostname; # Set the device hostname
  networking.wireless.enable = false; # Use Wi-Fi wia NetworkManager
  networking.networkmanager.enable = true;

  # Rename the network interface
  systemd.network.links = {
    "10-eth0" = {
      matchConfig.PermanentMACAddress = config.vars.ethernetMAC;
      linkConfig.Name = "eth0";
    };
  };

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

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
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };
}

