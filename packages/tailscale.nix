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

  # Enable IP forwarding for subnet routers
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  # TODO: this fixes MagicDNS but breaks DNS resolution on LAN (Pihole)
  # services.resolved.enable = true;
}

