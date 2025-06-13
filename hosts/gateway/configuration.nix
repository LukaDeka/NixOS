{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../packages/variables.nix # Provides config.vars.<option>
    # (modulesPath + "/installer/scan/not-detected.nix")
    # (modulesPath + "/profiles/qemu-guest.nix")
  ];

  vars.username = "luka";
  vars.hostname = "gateway";
  vars.email = "me@lukadeka.com";
  vars.domain = "lukadeka.com";
  vars.ethernetMAC = "96:00:04:5d:d2:0d";

  # Never prompt "wheel" users for a root password; potential security issue!
  security.sudo.wheelNeedsPassword = false;

  users.users  = {
    ${config.vars.username} = {
      isNormalUser = true;
      linger = true; # Keep user services running
      extraGroups = [ "networkmanager" "wheel" ];
      hashedPassword = "$y$j9T$nTWoHxqAJvwjcV70wHbQQ0$ePd3MfeST62/9eAlaHvi9iquC2j5PNQTCki8U8fznAD";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM/4F45h/xkq+MIRDzhHqDm5uWM4KTpYi3Tv/DtSo28t luka@gram" # EOS
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFxw+URmM/WpNRRwJpBgLL6EmXuYxA3SKItQZZyjXxw6 luka@berlin"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIT+vMzh2ngUeqnVJS8Zl1m1HQMBkDOqoGdoARPyJgDM u0_a380@localhost" # Termux
      ];
    };
    "root" = { # TODO: Remove this
      isSystemUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM/4F45h/xkq+MIRDzhHqDm5uWM4KTpYi3Tv/DtSo28t luka@gram" # EOS
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFxw+URmM/WpNRRwJpBgLL6EmXuYxA3SKItQZZyjXxw6 luka@berlin"
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    powertop
  ];

  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  nix.settings.trusted-users = [ config.vars.username ];

  system.stateVersion = "24.05";
}

