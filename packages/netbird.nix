{ config, lib, ... }:

let
  clientId = "328123977882992641";
  domain = config.vars.domain;
  netbirdDomain = "netbird.${domain}";
in
{
  imports = [ ./zitadel.nix ];

  services.netbird.enable = true; # Enable the client as well
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
      domain = netbirdDomain;
      turnDomain = netbirdDomain;
      singleAccountModeDomain = netbirdDomain;
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

        TURNConfig = {
          Secret._secret = "/etc/env/netbird/turn_password";
          CredentialsTTL = "12h";
          TimeBasedCredentials = false;
          Turns = [
            {
              Password._secret = "/etc/env/netbird/turn_password";
              Proto = "udp";
              URI = "turn:${netbirdDomain}:3478";
              Username = "netbird";
            }
          ];
        };
        Relay = {
          Addresses = [ "rel://${netbirdDomain}:33080" ];
          CredentialsTTL = "24h";
          Secret._secret = "/etc/env/netbird/relay_secret";
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

  virtualisation.oci-containers.containers.netbird-relay = {
    image = "netbirdio/relay:latest";
    ports = [
      "33080:33080"
    ];
    environment = {
      NB_LOG_LEVEL = "info";
      NB_LISTEN_ADDRESS = ":33080";
      NB_EXPOSED_ADDRESS = "${netbirdDomain}:33080";
    };
    environmentFiles = [
      "/etc/env/netbird/relay_secret_container"
    ];
  };

  networking.firewall.allowedTCPPorts = [ 80 443 3478 10000 33080 ];
  networking.firewall.allowedUDPPorts = [ 3478 5349 33080 ];
  networking.firewall.allowedUDPPortRanges = [{ from = 40000; to = 40050; }]; # TURN
}

