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

  time.timeZone = "Europe/Berlin";

  # Never prompt "wheel" users for a root password; potential security issue!
  security.sudo.wheelNeedsPassword = false;

  users.users  = {
    ${config.vars.username} = {
      isNormalUser = true;
      linger = true; # Keep user services running
      extraGroups = [ "networkmanager" "wheel" "nextcloud" "video" "audio" "tty" "input" "gamemode" ];
      hashedPassword = "$y$j9T$nTWoHxqAJvwjcV70wHbQQ0$ePd3MfeST62/9eAlaHvi9iquC2j5PNQTCki8U8fznAD";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM/4F45h/xkq+MIRDzhHqDm5uWM4KTpYi3Tv/DtSo28t luka@gram" # EOS
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICY63LU9IuSAAs4juNtaGWc067MuUH8LbhaNxQGKP4A1 u0_a637@localhost" # Termux
      ];
    };
    "root" = { # For sshfs
      isSystemUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM/4F45h/xkq+MIRDzhHqDm5uWM4KTpYi3Tv/DtSo28t luka@gram" # EOS
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    ######## Text editors ########
    vim

    ######## CLI QoL tools ########
    tmux
    wget
    fzf # TODO: Learn how to use fzf

    ######## Monitoring & tools ########
    zfs # Raid
    ffmpeg
    fastfetch
    wireguard-tools
    btop # Task manager
    iotop
    dool # dstat "fork"
    acpi # Battery level
    ncdu # Disk space
    usbutils
    smartmontools # smartctl
    hdparm
    dig
    unzip

    bluez
    bluez-tools
    bluetui # TUI for bluetooth
    alsa-utils # For speaker-test

    ######## Etc. ########
    cowsay
    qrencode
    iptables
    openssl # Generate secure passwords with: $ openssl rand -base64 48
    distrobuilder
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}

