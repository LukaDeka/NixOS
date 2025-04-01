{ config, pkgs, ... }:

let
  domain = config.vars.domain;
  ip = config.vars.ip;
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
    extraGroups = [ "render" ];
  };

  services.nginx.virtualHosts = {
    "jellyfin.${domain}" = {
      sslCertificate = "/etc/env/ssl/${domain}.pem";
      sslCertificateKey = "/etc/env/ssl/${domain}.key";
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://${ip}:8096";
        proxyWebsockets = true;
      };
    };
  };


  # Enable vaapi on OS-level
  # nixpkgs.config.packageOverrides = pkgs: {
  #   vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  # };

  boot.kernelParams = [
    "i915.enable_guc=2"
  ];

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
      vaapiVdpau
      intel-compute-runtime-legacy1
      # intel-compute-runtime
      intel-media-sdk
    ];
  };
}

