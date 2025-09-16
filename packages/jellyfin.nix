{ config, pkgs, ... }:

let
  domain = config.vars.domain;
  # ip = config.vars.privateIp;
in
{
  environment.systemPackages = [
    pkgs.jellyfin
    pkgs.jellyfin-web
    pkgs.jellyfin-ffmpeg
  ];

  services.jellyfin = {
    enable = true;
    openFirewall = true;
    user = config.vars.username;
    # dataDir = "${config.vars.storageDir}/jellyfin";
  };

  users.users.jellyfin = {
    isSystemUser = true;
    group = "jellyfin";
    extraGroups = [ "render" "video" ];
  };

  networking.firewall.allowedTCPPorts = [ 8096 ];

  # services.nginx.virtualHosts = {
  #   "jellyfin.${domain}" = {
  #     sslCertificate = "/etc/env/ssl/${domain}.pem";
  #     sslCertificateKey = "/etc/env/ssl/${domain}.key";
  #     forceSSL = true;
  #     enableACME = true;
  #     locations."/" = {
  #       proxyPass = "http://${ip}:8096";
  #       proxyWebsockets = true;
  #     };
  #   };
  # };

  boot.kernelParams = [
    "i915.enable_guc=2"
  ];

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver # For older processors
      vpl-gpu-rt # QSV
    ];
  };
}

