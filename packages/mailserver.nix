{ config, pkgs, ... }:

let
  domain = config.vars.domain;
  email = config.vars.email;
in
{
  mailserver = {
    enable = true;
    stateVersion = 3;
    fqdn = "mail.${domain}";
    domains = [ domain ];

    indexDir = "/var/search-index";
    fullTextSearch = {
      enable = true;
      autoIndex = true;
      languages = [ "en" "de" "ge" ];
    };

    backup = {
      enable = true;
    };

    virusScanning = true; # Memory-expensive

    rejectRecipients = [ # Block mails addressed to:
      "info@${domain}"
      "support@${domain}"
      "sales@${domain}"
      "contact@${domain}"
      "marketing@${domain}"
    ];

    # A list of all login accounts. To create the password hashes, use
    # $ mkpasswd -sm bcrypt
    loginAccounts = {
      "${email}" = {
        aliases = [ "@${domain}" ]; # Allow sending from every address
        catchAll = [ domain ];
        hashedPassword = "$2b$05$pvzxyP3Pgpijs/Fm5e.fMOSksfFVDvZt6WPLWnzLy1r6AGPiYkY36";
      };
      "no-reply@${domain}" = {
        sendOnly = true;
        hashedPassword = "$2b$05$arkLuEunhZPzreFE/4RjwOiDlufX8W..K8NrHQHIXhvzP9H1zIrbS";
      };
    };

    certificateScheme = "acme-nginx";
  };

  services.nginx.virtualHosts."mta-sts.${domain}" = {
    enableACME = true;
    forceSSL = true;
    locations."/".root = pkgs.writeTextFile {
      name = "mta-sts.txt";
      text = ''
        version: STSv1
        mode: enforce
        mx: mail.${domain}
        max_age: 86400
      '';
      destination = "/.well-known/mta-sts.txt";
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = email;
  };
}

