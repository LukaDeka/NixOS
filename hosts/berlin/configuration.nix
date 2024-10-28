# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix   # Include the results of the hardware scan
      ./networking.nix               # SSH, firewall settings

      ######## Server configuration ########
      ./../../modules/wireguard.nix  # VPN
      ./../../modules/samba.nix      # TODO: figure out what to do with samba
      # ./../../modules/nginx.nix      
      ./../../modules/seafile.nix      # TODO: TODO TODO TODO
      # ./../../modules/caddy.nix
      # ./../../modules/docker.nix     # TODO: Modularize config
      #./../../modules/blocky.nix     # DNS server/adblocker TODO: Diagnose why it's not working/switch to Pihole Docker container
      ./../../modules/aliases.nix    # BASH aliases
      # ./../../modules/fish.nix       # TODO: Learn fish
      ./../../modules/extra.nix      # Battery settings, lid close, etc.

      ######## Scripts ########
      ./../../scripts/scripts.nix    # TODO: Separate/modularize scripts
    ];

  networking.hostName = "berlin";

  boot.swraid.mdadmConf = ''
    MAILADDR=luka.dekanozishvili1@gmail.com
  '';

  # List packages installed in system profile. To search, run: nix search [package]
  environment.systemPackages = let
    unstable = inputs.unstable.legacyPackages.${pkgs.system};
  in (with unstable; [
    #seafile-server
    #seahub
  ]) ++ (with pkgs; [
    ######## Must-haves ########
    vim
    neovim
    tmux
    git
    wget
    fzf # TODO: Learn how to use this

    ######## Server programs ########
    # nextcloud29
    # nginx
    # caddy
    # docker
    # docker-compose
    #unstable.seafile-server
    #unstable.seahub

    wireguard-tools
    iptables
    mdadm

    ######## Monitoring & tools ########
    btop
    acpi 
    ncdu
    qrencode

    ######## Etc. ########
    fastfetch
  ]);

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’
  users.users.luka = {
    isNormalUser = true;
    description = "luka";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  # Never prompt "wheel" users for a root password; potential security issue!
  security.sudo.wheelNeedsPassword = false;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}

