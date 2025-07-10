{ config, lib, ... }:

let
  domain = config.vars.domain;
  username = config.vars.username;
  clientId = "328123977882992641";
  netbirdDomain = "netbird.${domain}";
in
{
  services.netbird.server = {
    enable = true;
    enableNginx = true;
    domain = netbirdDomain;

    coturn = {
      enable = true;
      domain = netbirdDomain;
      passwordFile = "/etc/env/netbird/turn_password";
      # useAcmeCertificates = true; # ?
    };

    signal = {
      enable = true;
      enableNginx = true;
      domain = netbirdDomain;
    };

    dashboard = {
      enable = true;
      enableNginx = true;
      domain = netbirdDomain;
      settings = {
        AUTH_AUTHORITY = "https://auth.${domain}";
        AUTH_CLIENT_ID = clientId;
        AUTH_AUDIENCE = clientId;
        # AUTH_CLIENT_ID = "netbird";
        # AUTH_AUDIENCE = "netbird";
      };
    };

    management = {
      enable = true;
      enableNginx = true;
      oidcConfigEndpoint = "https://auth.${domain}/.well-known/openid-configuration";
      # For Authentik:
      # oidcConfigEndpoint = "https://auth.${domain}/application/o/netbird/.well-known/openid-configuration";

      settings = {
        Signal.URI = "${netbirdDomain}:443";

        HttpConfig = {
          AuthAudience = clientId;
          # AuthAudience = "netbird";
        };
        IdpManagerConfig = {
          # ManagerType = "none";
          ClientConfig = {
            # Issuer = "";
            # TokenEndpoint = "";
            ClientID = clientId;
            # ClientSecret = "";
            # GrantType = "client_credentials";
          };
        };
        DeviceAuthorizationFlow = {
          # Provider = "none";
          ProviderConfig = {
            Audience = clientId;
            # Domain = null;
            ClientID = clientId;
            # TokenEndpoint = null;
            # DeviceAuthEndpoint = "";
            # Scope = "openid profile email offline_access api";
            # UseIDToken = false;
          };
        };
        PKCEAuthorizationFlow = {
          ProviderConfig = {
            Audience = clientId;
            ClientID = clientId;
            # ClientSecret = "";
            # AuthorizationEndpoint = "";
            # TokenEndpoint = "";
            # Scope = "openid profile email offline_access api";
            # RedirectURLs = "http://localhost:53000";
            # UseIDToken = false;
          };
        };

        # TURNConfig = {
        #   Turns = [{
        #     Proto = "udp";
        #     URI = "turn:${netbirdDomain}:3478";
        #     Username = username;
        #     Password._secret = "/etc/env/netbird/turn_password";
        #   }];
        # };
        TURNConfig = {
          Secret._secret = "/etc/env/netbird/turn_password";
        };

        DataStoreEncryptionKey._secret = "/etc/env/netbird/data_store_encryption_key";
      };
    };
  };

  systemd.services.netbird-management.serviceConfig = {
    EnvironmentFile = "/etc/env/netbird/setup.env";
  };

  # Override ACME settings to get cert
  services.nginx.virtualHosts = lib.mkMerge [
    {
      "${netbirdDomain}" = {
        enableACME = true;
        forceSSL = true;
      };
    }
  ];

  networking.firewall.allowedTCPPorts = [ 80 443 3478 10000 ];
  networking.firewall.allowedUDPPorts = [ 3478 10000 ];
}

