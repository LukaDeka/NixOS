{ config, pkgs, ... }:

let
  retroarchWithCores = (pkgs.retroarch.withCores (cores: with cores; [
    # More cores are available in:
    # https://github.com/NixOS/nixpkgs/tree/master/pkgs/applications/emulators/libretro/cores
    genesis-plus-gx # Sega Genesis/Mega Drive
    mesen # NES
    snes9x # SNES
    dolphin # WII
    beetle-psx # PS1
  ]));
in
{
  environment.systemPackages = with pkgs; [
    retroarchWithCores
  ];

  services.xserver = {
    enable = true;
    autorun = false;

    # Use startx to manually launch graphical session
    displayManager.startx.enable = true;

    # Set up the screen
    xrandrHeads = [
      {
        output = "DP-2-2";
        primary = true;
        monitorConfig = ''
          Modeline "1920x1080_74.97"  220.75  1920 2056 2264 2608  1080 1083 1088 1130 -hsync +vsync
          Option "PreferredMode" "1920x1080_74.97"
        '';
      }
    ];
  };

  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}

