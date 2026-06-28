{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ tailscale ethtool ];

  services.tailscale = {
    enable = true;
    openFirewall = true;
    useRoutingFeatures = "both"; # Act as a client and a server (exit node)

    extraSetFlags = [
      "--advertise-exit-node"
      "--advertise-routes=10.10.0.0/16"
    ];

    disableUpstreamLogging = true;
    disableTaildrop = true;
  };

  # Persist UDP GRO forwarding settings for exit node / subnet router performance
  services.networkd-dispatcher = {
    enable = true;
    rules."50-tailscale-optimizations" = {
      onState = [ "routable" ];
      script = ''
        #!${pkgs.runtimeShell}
        netdev=$(${pkgs.iproute2}/bin/ip -o route get 1.1.1.1 | cut -f 5 -d " ")
        ${pkgs.ethtool}/bin/ethtool -k "$netdev" rx-udp-gro-forwarding on rx-gro-list off
      '';
    };
  };

  # Enable ip forwarding for subnet routers
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  # TODO: this fixes magicdns but breaks dns resolution on lan (pihole)
  # services.resolved.enable = true;
}

