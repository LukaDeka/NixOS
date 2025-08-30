{ config, pkgs, ... }:

let
  host = config.vars.hostname;
  homeDir = config.vars.homeDir;
in
{
  programs.zsh = {
    shellAliases = {
      ll = "ls -Ahlv --time-style=iso --group-directories-first";
      l  = "ls -hgov --time-style=iso --group-directories-first";

      done = "speaker-test -t wav -w ${homeDir}/nixos/misc/done_sfx.wav -l 1 >/dev/null";

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

      s =  "cd ${homeDir}/nixos; git add . && sudo nixos-rebuild switch --flake ${homeDir}/nixos; cd - &> /dev/null";
      sr = "cd ${homeDir}/nixos; git add . && export NIX_SSHOPTS='-p 6868' && nixos-rebuild switch --flake ${homeDir}/nixos#hetzner --target-host \"luka@91.99.69.65\" --sudo; cd - &> /dev/null";
    };
    # shellInit = ''
    #   export COLORTERM=truecolor;
    # '';
  };
}

