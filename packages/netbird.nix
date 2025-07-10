{ config, lib, ... }:

let
  clientId = "328123977882992641";
  domain = config.vars.domain;
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

        HttpConfig.AuthAudience = clientId;
        IdpManagerConfig.ClientConfig.ClientID = clientId;
        DeviceAuthorizationFlow.ProviderConfig = {
          Audience = clientId;
          ClientID = clientId;
        };
        PKCEAuthorizationFlow.ProviderConfig = {
          Audience = clientId;
          ClientID = clientId;
        };

        TURNConfig.Secret._secret = "/etc/env/netbird/turn_password";
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

