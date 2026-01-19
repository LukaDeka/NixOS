{ pkgs, config, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  networking.hostName = "hexname-ns1";
  networking.networkmanager.enable = true;

  users.users = {
    luka = {
      isNormalUser = true;
      linger = true; # Keep user services running
      extraGroups = [ "networkmanager" "wheel" "podman" ];
      hashedPassword = "$y$j9T$6bEHYFO.AGCC2bnKxC3xB/$6/1zmuzaSvDSHID6ZTgnrHiWRS8ayEXhNBp48ugR4z7";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM/4F45h/xkq+MIRDzhHqDm5uWM4KTpYi3Tv/DtSo28t luka@gram"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF7OvW6MffYFshZyarEaWvWjEmhodn/P+NLcnqbbMpma luka@conway"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIT+vMzh2ngUeqnVJS8Zl1m1HQMBkDOqoGdoARPyJgDM u0_a380@localhost" # s
      ];
    };
    root = {
      isSystemUser = true;
      hashedPassword = "$y$j9T$6bEHYFO.AGCC2bnKxC3xB/$6/1zmuzaSvDSHID6ZTgnrHiWRS8ayEXhNBp48ugR4z7";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM/4F45h/xkq+MIRDzhHqDm5uWM4KTpYi3Tv/DtSo28t luka@gram"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF7OvW6MffYFshZyarEaWvWjEmhodn/P+NLcnqbbMpma luka@conway"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIT+vMzh2ngUeqnVJS8Zl1m1HQMBkDOqoGdoARPyJgDM u0_a380@localhost" # s
      ];
    };
  };

  programs.git = {
    enable = true;
    config = {
      user.name = "Luka Dekanozishvili";
      user.email = "me@lukadeka.com";
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
      dates = "Mon *-*-* 09:00:00";
      options = "--delete-older-than 90d";
    };
  };

  nix.settings.trusted-users = [ "luka" ]; # TODO: remove this line

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  boot.supportedFilesystems = [ "zfs" ];
  networking.hostId = "11111111"; # $ head -c 8 /etc/machine-id

  system.stateVersion = "25.11";
}

