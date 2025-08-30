{ config, pkgs, ... }:

let
  domain = config.vars.domain;
in
{
  virtualisation.oci-containers.containers.frigate = {
    image = "ghcr.io/blakeblackshear/frigate:stable";

    devices = [
      "/dev/dri/renderD128:/dev/dri/renderD128"
    ];

    ports = [
      "8971:8971"
      "8554:8554" # RTSP feeds
      "8555:8555/tcp" # WebRTC over tcp
      "8555:8555/udp" # WebRTC over udp
    ];

    volumes = [
      "/etc/localtime:/etc/localtime:ro"
      "/zfs/frigate/config:/config"
      "/zfs/frigate/storage:/media/frigate"
    ];

    environmentFiles = [ "/etc/env/frigate/envfile" ];

    extraOptions = [
      "--cap-add=NET_ADMIN"
    ];
  };

  networking.firewall.allowedTCPPorts = [ 8971 8554 8555 ];
  networking.firewall.allowedUDPPorts = [ 8971 8555 ];
}

