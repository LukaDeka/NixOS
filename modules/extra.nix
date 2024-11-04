{ config, pkgs, ... }:

{
  # Keep laptop running with lid closed
  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
    AllowHybridSleep=no
    AllowSuspendThenHibernate=no
  '';

  # Enable battery care (charge up to 50%)
  services.tlp = {
    enable = true;
    settings = {
      START_CHARGE_THRESH_BAT0 = 40;
      STOP_CHARGE_THRESH_BAT0 = 50;

      START_CHARGE_THRESH_BAT1 = 40;
      STOP_CHARGE_THRESH_BAT1 = 50;
    };
  };

  # Add fonts
  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "CascadiaMono" ]; })
  ];
}

