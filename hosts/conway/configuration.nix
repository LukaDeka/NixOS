{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../packages/variables.nix # Provides config.vars.<option>
  ];

  vars.username = "luka";
  vars.hostname = "conway";
  vars.email = "me@lukadeka.com";
  vars.domain = "lukadeka.com";
  #vars.ip = "10.10.10.10";
  vars.ethernetMAC = "34:5a:60:63:d7:42";
  #vars.storageDir = "/zfs";

  time.timeZone = "Europe/Berlin";

  # Never prompt "wheel" users for a root password; potential security issue!
  security.sudo.wheelNeedsPassword = false;

  users.users  = {
    ${config.vars.username} = {
      isNormalUser = true;
      linger = true; # Keep user services running
      extraGroups = [ "networkmanager" "wheel" "nextcloud" "docker" "video" "audio" "tty" "input" "gamemode" ];
      hashedPassword = "$y$j9T$6bEHYFO.AGCC2bnKxC3xB/$6/1zmuzaSvDSHID6ZTgnrHiWRS8ayEXhNBp48ugR4z7";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM/4F45h/xkq+MIRDzhHqDm5uWM4KTpYi3Tv/DtSo28t luka@gram"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIT+vMzh2ngUeqnVJS8Zl1m1HQMBkDOqoGdoARPyJgDM u0_a380@localhost" # s
      ];
    };
    "root" = { # For sshfs
      isSystemUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM/4F45h/xkq+MIRDzhHqDm5uWM4KTpYi3Tv/DtSo28t luka@gram"
      ];
    };
  };

  services.netbird.enable = true;

  environment.systemPackages = with pkgs; [
    fzf # TODO: Learn how to use fzf

    zfs # Raid
    ffmpeg

    alsa-utils # For speaker-test
    powertop

    qrencode
    iperf
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "zfs" ];

  system.stateVersion = "25.05";
}

