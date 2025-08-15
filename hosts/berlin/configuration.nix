{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../packages/variables.nix # Provides config.vars.<option>
  ];

  vars.username = "luka";
  vars.hostname = "berlin";
  vars.email = "luka.dekanozishvili1@gmail.com";
  vars.domain = "lukadeka.com";
  vars.storageDir = "/zfs";

  vars.privateIp = "10.10.10.10";
  vars.serverNetbirdIp = "100.124.116.159"; # This server's IP
  vars.proxyNetbirdIp = "100.124.117.109";
  vars.ethernetMAC = "54:e1:ad:6e:4e:d1";

  time.timeZone = "Europe/Berlin";

  # Never prompt "wheel" users for a root password; potential security issue!
  security.sudo.wheelNeedsPassword = false;

  users.users  = {
    ${config.vars.username} = {
      isNormalUser = true;
      linger = true; # Keep user services running
      extraGroups = [ "networkmanager" "wheel" "nextcloud" "docker" "video" "audio" "tty" "input" "gamemode" ];
      hashedPassword = "$y$j9T$nTWoHxqAJvwjcV70wHbQQ0$ePd3MfeST62/9eAlaHvi9iquC2j5PNQTCki8U8fznAD";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM/4F45h/xkq+MIRDzhHqDm5uWM4KTpYi3Tv/DtSo28t luka@gram"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINWaGWnJ1wi0EqdhB20DqvB8M/zZ606nBTeUNG2MskXx luka@tbilisi"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIT+vMzh2ngUeqnVJS8Zl1m1HQMBkDOqoGdoARPyJgDM u0_a380@localhost" # s
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF7OvW6MffYFshZyarEaWvWjEmhodn/P+NLcnqbbMpma luka@conway"
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
    restic
    ffmpeg

    alsa-utils # For speaker-test
    powertop

    qrencode
    iperf
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  system.stateVersion = "24.05";
}

