{ config, pkgs, ... }:

let
  host = config.vars.hostname;
  homeDir = config.vars.homeDir;
in
{
  programs.bash = {
    shellAliases = {
      ll = "ls -Ahlv --time-style=iso --group-directories-first";
      l  = "ls -hgov --time-style=iso --group-directories-first";
      gs = "git status";
      ga = "git add .";
      ".." = "cd ..";
      n = "cd ${homeDir}/nixos";
      f = "vim ${homeDir}/nixos/flake.nix";
      c = "vim ${homeDir}/nixos/hosts/${host}/configuration.nix";
      s = "git add ${homeDir}/nixos/. && sudo nixos-rebuild switch --flake ${homeDir}/nixos";
    };
    shellInit = ''
      export COLORTERM=truecolor;
    '';
  };
}

