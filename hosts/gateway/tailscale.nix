{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ tailscale ethtool ];

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

  # Enable ip forwarding for subnet routers
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  # TODO: this fixes magicdns but breaks dns resolution on lan (pihole)
  # services.resolved.enable = true;
}

