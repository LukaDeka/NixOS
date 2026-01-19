{ ... }:

let
  domain = "hexname.com";
in
{
  services.powerdns = {
    enable = true

    # To hash the api-key, use:
    # $ pdnsutil hash-password
    extraConfig = ''
      api=true
      api-key=
      primary=yes
      webserver-address=127.0.0.1
      webserver-port=8081
      local-address=0.0.0.0:53
      webserver-allow-from=127.0.0.1/32
      version-string=anonymous
      default-ttl=1500
    '';
  };
}

