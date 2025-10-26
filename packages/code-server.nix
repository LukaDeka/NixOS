{ config, pkgs, ... }:

let
  domain = config.vars.domain;
  homeDir = config.vars.homeDir;
  user = config.vars.username;
  group = "users";
  # host = "100.92.201.89"; # conway
  # host = "10.10.10.10"; # HTTP on LAN
  host = "127.0.0.1";
in
{
  services.code-server = {
    enable = true;
    package = pkgs.vscode-with-extensions.override {
      vscode = pkgs.code-server;
      vscodeExtensions = with pkgs.vscode-extensions; [
        vscodevim.vim
        ms-vscode-remote.remote-ssh
        jdinhlife.gruvbox
        ##### LSPs #####
        bbenoist.nix
        rust-lang.rust-analyzer
      ];
    };
    inherit user;
    inherit group;
    inherit host;
    port = 19942;
    proxyDomain = "code.${domain}";

    # userDataDir = homeDir;
    auth = "password";
    # $ printf "password" | sha256sum | cut -d' ' -f1
    hashedPassword = "8421fb6e593e47b10dc9e1f87af98552c85efa16f2499fdd493b4792bd32ce76";

    disableTelemetry = true;
    disableGettingStartedOverride = true;
    disableWorkspaceTrust = true;
    disableUpdateCheck = true;
  };

   networking.firewall.allowedTCPPorts = [ 19942 ];

  services.nginx.virtualHosts."10.10.10.10" = {
    # forceSSL = true;
    # enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:19942";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
      '';
    };
  };
}

