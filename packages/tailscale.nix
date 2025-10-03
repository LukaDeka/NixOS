{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ tailscale ];
  services.tailscale = {
    enable = true;
    openFirewall = true;
    useRoutingFeatures = "both"; # Act as a client and a server (exit node)

    extraSetFlags = [
      "--advertise-exit-node"
    ];

    disableUpstreamLogging = true;
    disableTaildrop = true;
  };
}

