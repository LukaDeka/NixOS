{ config, pkgs, ... }:

{
  # Keep laptop running with lid closed
  systemd.sleep.extraConfig = ''
    AllowSuspend=no
  '';

    #AllowHibernation=no
    #AllowHybridSleep=no
    #AllowSuspendThenHibernate=no
  #services.logind.lidSwitch = "ignore";
  #services.logind.lidSwitchExternalPower = "ignore";
  #services.logind.lidSwitchDocked = "ignore";

  # Enable battery care (charge up to 50% by default)
  services.tlp = {
    enable = true;
    settings = {
      START_CHARGE_THRESH_BAT0 = config.vars.startChargeThresh;
      STOP_CHARGE_THRESH_BAT0 = config.vars.stopChargeThresh;

      START_CHARGE_THRESH_BAT1 = config.vars.startChargeThresh;
      STOP_CHARGE_THRESH_BAT1 = config.vars.stopChargeThresh;
    };
  };

  # Add fonts
  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "CascadiaMono" ]; })
  ];
}

