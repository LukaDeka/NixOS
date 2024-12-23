{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../../packages/variables.nix # Provides config.vars.<option>
    ];

  vars.username = "luka";
  vars.hostname = "berlin";
  vars.email = "luka.dekanozishvili1@gmail.com";
  vars.domain = "lukadeka.com";
  vars.ddnsDomain = "lukadeka.duckdns.org";
  vars.ip = "10.10.10.10";
  vars.ethernetMAC = "54:e1:ad:6e:4e:d1";
  vars.storageDir = "/zfs";

  users.users.${config.vars.username} = {
    isNormalUser = true;
    linger = true; # Keep user services running
    extraGroups = [ "networkmanager" "wheel" "audio" ];
    hashedPassword = "$y$j9T$nTWoHxqAJvwjcV70wHbQQ0$ePd3MfeST62/9eAlaHvi9iquC2j5PNQTCki8U8fznAD";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFXTIyuRIpZhHkPZwwK2ZedlxtqkzAE9UQidyu3ah6xZ lukad@gram" # Win11
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGIq7SWl7gSb2WVrjInZpEIYxo0RcuSIh/KMuVfAdnKb luka" # WSL
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICY63LU9IuSAAs4juNtaGWc067MuUH8LbhaNxQGKP4A1 u0_a637@localhost" # Termux
    ];
  };

  #security.rtkit.enable = true;
  #services.pipewire = {
  #  enable = true;

  #  alsa.enable = true;
  #  alsa.support32Bit = true;
  #  pulse.enable = true;
  #  socketActivation = false;
  #};
  # Start WirePlumber (with PipeWire) at boot.
  #systemd.user.services.wireplumber.wantedBy = [ "default.target" ];

  environment.systemPackages = with pkgs; [
    ######## Text editors ########
    vim
    # lunarvim
    # helix
    # nil # Nix language server

    ######## CLI tools ########
    tmux
    wget
    fzf # TODO: Learn how to use fzf
    wireguard-tools

    ######## Monitoring & tools ########
    fastfetch
    zfs # Raid
    btop # Task manager
    iotop
    dool # dstat "fork"
    acpi # Battery level
    ncdu # Disk space
    hdparm
    smartmontools # smartctl

    ######## Etc. ########
    cowsay
    qrencode
    iptables
    openssl # Generate secure passwords with: $ openssl rand -base64 48
  ];

  # Never prompt "wheel" users for a root password; potential security issue!
  security.sudo.wheelNeedsPassword = false;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = let
    locale = "de_DE.UTF-8";
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
    package = pkgs.nixVersions.latest;
    extraOptions = ''
      warn-dirty = false
    '';
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}

