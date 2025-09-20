{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../packages/variables.nix # Provides config.vars.<option>
  ];

  vars.username = "luka";
  vars.hostname = "tbilisi";
  vars.email = "luka.dekanozishvili1@gmail.com";
  vars.domain = "dekanozishvili.cloud";
  vars.storageDir = "/zfs";

  vars.privateIp = "192.168.1.50";
  vars.serverNetbirdIp = "100.124.170.101";
  vars.ethernetMAC = "28:d2:44:e8:bc:b5";

  time.timeZone = "Asia/Tbilisi";

  # Never prompt "wheel" users for a root password; potential security issue!
  security.sudo.wheelNeedsPassword = false;

  users.users.${config.vars.username} = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
    hashedPassword = "$y$j9T$nTWoHxqAJvwjcV70wHbQQ0$ePd3MfeST62/9eAlaHvi9iquC2j5PNQTCki8U8fznAD";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM/4F45h/xkq+MIRDzhHqDm5uWM4KTpYi3Tv/DtSo28t luka@gram" # EOS
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF7OvW6MffYFshZyarEaWvWjEmhodn/P+NLcnqbbMpma luka@conway"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIT+vMzh2ngUeqnVJS8Zl1m1HQMBkDOqoGdoARPyJgDM u0_a380@localhost"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFxw+URmM/WpNRRwJpBgLL6EmXuYxA3SKItQZZyjXxw6 luka@berlin"
    ];
  };

  services.netbird.enable = true;

  environment.systemPackages = with pkgs; [
    zfs # Raid
    ffmpeg
    restic
    powertop
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  system.stateVersion = "24.05";
}

