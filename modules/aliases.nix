{ config, pkgs, ... }:

{
  programs.bash.shellAliases = {
    ll = "ls -Ahlv --time-style=iso --group-directories-first";
    l  = "ls -hgov --time-style=iso --group-directories-first";
    gs = "git status";
    ga = "git add .";
    ".." = "cd ..";
    n = "cd /home/luka/nixos";
    c = "vim /home/luka/nixos/hosts/berlin/configuration.nix";
    s = "sudo git add .; sudo nixos-rebuild switch --flake ~/nixos --option eval-cache false";
    vim = "nvim";
  };
}

