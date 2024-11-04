{ config, pkgs, ... }:

{
  services.caddy = {
    enable = true;
    virtualHosts = {
      "seafile.lukadeka.com".extraConfig = ''
        tls /etc/ssl/certs/lukadeka.com.pem /etc/ssl/certs/lukadeka.com.key
        # reverse_proxy http://127.0.0.1:39998 

        handle_path /seafile/notification/* {
          @websockets {
            header Connection *Upgrade*
            header Upgrade    websocket
          }
          reverse_proxy @websockets 127.0.0.1:8083
        }
        handle_path /seafhttp* {
          reverse_proxy 127.0.0.1:8082
        }
        handle_path /seafdav* {
          reverse_proxy 127.0.0.1:8080
        }
        handle_path /media* {
          root * /var/lib/seafile/seahub
          file_server
        }
        handle {
          reverse_proxy 127.0.0.1:39998
        }
      '';

      "nextcloud.lukadeka.com".extraConfig = ''
        tls /etc/ssl/certs/lukadeka.com.pem /etc/ssl/certs/lukadeka.com.key
	reverse_proxy http://127.0.0.1:39996
      '';
    };
  };
}
