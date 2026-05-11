{ config, ... }:

let
  domain = config.vars.domain;
in
{
  services.nginx.virtualHosts."immich.${domain}" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://conway:2283";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_set_header Host              $host;
        proxy_set_header X-Real-IP         $remote_addr;
        proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # Allow large file uploads
        client_max_body_size 50000M;

        # Increase body buffer to avoid limiting upload speed
        client_body_buffer_size 1024k;

        # Disable buffering uploads to prevent OOM on reverse proxy server and make uploads twice as fast (no pause)
        proxy_request_buffering off;

        # Set timeout
        proxy_read_timeout 600s;
        proxy_send_timeout 600s;
        send_timeout       600s;
      '';
    };
  };
}

