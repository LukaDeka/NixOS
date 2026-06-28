# Tailscale exit-node container. qBittorrent shares its network namespace,
# so all torrent traffic (TCP/UDP/DHT) routes through tailscale-exit automatically.
#
# Verify:  sudo podman exec tailscale-qbt tailscale status
# Re-auth: sudo podman exec tailscale-qbt tailscale up \
#            --exit-node=100.125.50.21 --exit-node-allow-lan-access=true \
#            --hostname=conway-qbt --accept-routes --accept-dns=false
#
# WebUI access from any Tailscale peer: http://conway-qbt:8080

{ ... }:

{
  virtualisation.oci-containers.containers.tailscale-qbt = {
    image = "ghcr.io/tailscale/tailscale:stable";
    autoStart = true;
    networks = [ "servarr" ];
    extraOptions = [
      "--ip=10.89.1.100"
      "--cap-add=NET_ADMIN"
      "--cap-add=NET_RAW"
      "--device=/dev/net/tun:/dev/net/tun"
      "--sysctl=net.ipv4.ip_forward=1"
      "--sysctl=net.ipv6.conf.all.forwarding=1"
    ];
    volumes = [ "/var/lib/servarr/tailscale-qbt:/var/lib/tailscale" ];
    environmentFiles = [ "/etc/env/servarr/tailscale.env" ];
    environment = {
      TS_USERSPACE             = "false";
      TS_TAILSCALED_EXTRA_ARGS = "--tun=tailscale-exit --verbose=-1 --state=/var/lib/tailscale/tailscaled.state";
      TS_EXTRA_ARGS            = "--exit-node=100.125.50.21 --exit-node-allow-lan-access=true --accept-dns=false --hostname=conway-qbt --accept-routes";
    };
  };
}
