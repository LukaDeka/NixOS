{ config, pkgs, ... }:

{
  # Keep laptop running with lid closed
  systemd.sleep.extraConfig = ''
    AllowSuspend=no
  '';

  # Prevents the overheating of Intel CPUs
  services.thermald.enable = true;

  powerManagement.powertop.enable = true;

  # Enable battery care (charge up to 50% by default)
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 20;

      START_CHARGE_THRESH_BAT0 = config.vars.startChargeThresh;
      STOP_CHARGE_THRESH_BAT0 = config.vars.stopChargeThresh;

      START_CHARGE_THRESH_BAT1 = config.vars.startChargeThresh;
      STOP_CHARGE_THRESH_BAT1 = config.vars.stopChargeThresh;
    };
  };
}

