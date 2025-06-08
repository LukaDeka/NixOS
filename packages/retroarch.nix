{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    retroarch-full
  ];

  services.xserver = {
    enable = true;
    autorun = false;

    # Use startx to manually launch graphical session
    displayManager.startx.enable = true;

    # Set up the screen
    xrandrHeads = [
      "DP-2-2" { # Projector screen
        output = "DP-2-2";
        primary = true;
        monitorConfig = ''
          Modeline "1920x1080_60.00"  173.00  1920 2048 2248 2576  1080 1083 1088 1120 -hsync +vsync
          option "preferredmode" "1920x1080_60.00"
        '';
        # For the external monitor
        # monitorConfig = ''
        #   modeline "1920x1080_74.97"  220.75  1920 2056 2264 2608  1080 1083 1088 1130 -hsync +vsync
        #   option "preferredmode" "1920x1080_74.97"
        # '';
      }

      "eDP-1" { # Integrated screen
        output = "eDP-1";
        monitorConfig = ''
          Option "Ignore" "true"
        '';
      }
    ];
  };

  programs.gamemode.enable = true;

  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  # Enable bluetooth for controllers
  # hardware.bluetooth = {
  #   enable = true;
  #   powerOnBoot = true;
  #   settings = {
  #     General = {
  #       ControllerMode = "bredr";
  #     };
  #   };
  # };

  # Audio settings
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}

