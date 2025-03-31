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
      gd = "git diff";
      gp = "git push";
      gr = "git restore";

      du = "du -sh";

      ".." = "cd ..";

      n = "cd ${homeDir}/nixos";
      f = "vim ${homeDir}/nixos/flake.nix";
      c = "vim ${homeDir}/nixos/hosts/${host}/configuration.nix";
      s = "cd ${homeDir}/nixos && git add . && sudo nixos-rebuild switch --flake ${homeDir}/nixos; cd - &> /dev/null";
    };
    shellInit = ''
      export COLORTERM=truecolor;
    '';
  };
}

