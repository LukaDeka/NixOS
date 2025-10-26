{ config, inputs, lib, pkgs, ... }:

let
  domain = config.vars.domain;
  stalwartDomain = "mail.${domain}";
  roundcubeDomain = "webmail.${domain}";

  dataDir = "/var/lib/stalwart-mail";
  credPath = "/run/credentials/stalwart-mail.service";
in
{
  services.stalwart-mail = {
    enable = true;
    package = pkgs.stalwart-mail;
    openFirewall = true;

    settings = {
      server = {
        hostname = stalwartDomain;
        tls = {
          enable = true;
          implicit = true;
        };
        listener = {
          smtp = {
            bind = [ "[::]:25" ];
            protocol = "smtp";
          };
          submission = {
            bind = [ "[::]:587" ];
            protocol = "smtp";
          };
          submissions = {
            bind = [ "[::]:465" ];
            protocol = "smtp";
            tls.implicit = true;
          };
          imap = {
            bind = [ "[::]:143" ];
            protocol = "imap";
          };
          imaps = {
            bind = [ "[::]:993" ];
            protocol = "imap";
            tls.implicit = true;
          };
          http = {
            bind = [ "[::]:51020" ];
            protocol = "http";
            url = "https://${stalwartDomain}";
          };
        };
      };

      directory."in-memory" = {
        type = "memory";
        # Generate hashes with:
        # $ openssl passwd -6
        principals = [
          {
            name = "me@${domain}";
            email = [ "me@${domain}" "@${domain}" ];
            secret = "$6$E8AhTdIdgl2ag6/x$reYvoPByjvkPK/Uwm3/481BBBkuBKQxd3rgSgQw3PawJ4G8TOt0jlIXdOo5xuDv1DQAdn52lUAgx0U9GSVoc7/";
            class = "individual";
          }
          {
            name = "no-reply@${domain}";
            email = [ "no-reply@${domain}" ];
            secret = "$6$V/u1LImVZAyynuLO$l/mMaLWQ5t0jWz6XWNlHcha8nuTQbjQfES.Nj73mNS0xQjv3vu5z03fLMAt3hxAb5BwE3jgtfmh.PknBjM1M//";
            class = "individual";
          }
        ];
      };

      authentication.fallback-admin = {
        user = "superdupermegaadmin";
        secret = "$6$LPDx0LFqtpAVJO2s$GPR/4Rguhmspy8OLLKI2oZxVgvWrlHRckd6WN2RZNMxkSN9YMiPJ/pfq.XD/VTKsqCu2GCnzerQOv5bivBCph.";
      };

      email.folders = let
        mkFolder = name: {
          inherit name;
          create = true;
          subscribe = true;
        };
      in {
        inbox = mkFolder "Inbox";
        sent = mkFolder "Sent";
        drafts = mkFolder "Drafts";
        archive = mkFolder "Archive";
        junk = mkFolder "Spam";
        trash = mkFolder "Trash";
      };

      session.rcpt = {
        catch-all = true;
        script = "'reject-addresses'";
      };

      sieve.trusted.scripts.reject-addresses.contents = ''
        require ["envelope", "reject"];

        if anyof (
          envelope :is "to" "no-reply@${domain}"
          envelope :is "to" "spam@${domain}",
          envelope :is "to" "info@${domain}",
          envelope :is "to" "contact@${domain}",
          envelope :is "to" "support@${domain}"
          envelope :is "to" "marketing@${domain}",
          envelope :is "to" "sales@${domain}"
        ) {
          reject "403 This address does not accept incoming mails.";
        }

        redirect "me@${domain}";
      '';

      # Change the DNS records manually to these addresses to
      # keep postmaster free for non-automated emails
      # https://github.com/stalwartlabs/mail-server/discussions/877
      report.analysis = {
        addresses = [
          "dmarc-reports@*"
          "tls-reports@*"
          "spf-reports@*"
        ];
        forward = false;
      };

      # Stop warnings about what's managed where
      config.local-keys = [
        "authentication.fallback-admin.*"
        "certificate.*"
        "cluster.node-id"
        "directory.*"
        "email.folders.*"
        "lookup.default.domain"
        "lookup.default.hostname"
        "report.analysis.*"
        "resolver.*"
        "server.*"
        "!server.blocked-ip.*"
        "session.mta-sts.*"
        "session.rcpt.catch-all"
        "session.rcpt.script"
        "sieve.trusted.scripts.*"
        "spam-filter.resource"
        "storage.blob"
        "storage.data"
        "storage.directory"
        "storage.fts"
        "storage.lookup"
        "store.*"
        "tracer.*"
        "webadmin.*"
      ];

      # Store blobs in the file system for easier backups.
      # Since the database is backed up to /tmp, it would not fit in RAM
      # with all the blobs.
      store.fs = {
        type = "fs";
        path = "${dataDir}/blobs";
      };
      storage.blob = "fs";

      # We have DANE and don't want a certificate for each domain
      # session.mta-sts.mode = "none";

      certificate.default = {
        cert = "%{file:${credPath}/cert.pem}%";
        private-key = "%{file:${credPath}/key.pem}%";
        default = true;
      };

      lookup.default = {
        inherit domain;
        hostname = stalwartDomain;
      };

      tracer.stdout.level = "info";
    };
  };

  networking.firewall.allowedTCPPorts = [ 25 143 465 587 993 ];

  systemd.services.stalwart-mail = {
    wants = [ "acme-${stalwartDomain}.service" ];
    after = [ "acme-${stalwartDomain}.service" ];
    preStart = ''
      mkdir -p ${dataDir}/db
    '';
    serviceConfig = {
      LogsDirectory = "stalwart-mail";
      LoadCredential = [
        "cert.pem:${config.security.acme.certs.${stalwartDomain}.directory}/cert.pem"
        "key.pem:${config.security.acme.certs.${stalwartDomain}.directory}/key.pem"
      ];
    };
  };

  services.roundcube = {
    enable = true;
    package = pkgs.roundcube;
    dicts = with pkgs.aspellDicts; [ en de ];
    hostName = roundcubeDomain;
    plugins = [
      "archive"
      "zipdownload"
      "acl"
    ];
    extraConfig = ''
      $config['imap_host'] = 'ssl://${stalwartDomain}:993';
      $config['smtp_host'] = 'ssl://%h:465';
      $config['mail_domain'] = '%z';
    '';
  };

  services.nginx.virtualHosts = let
    proxy = "http://localhost:51020";
  in {
    ${stalwartDomain} = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = proxy;
    };
    ${roundcubeDomain}.locations."/".extraConfig = ''
      add_header Cache-Control "public, max-age=604800, must-revalidate" always;
      add_header Referrer-Policy "origin-when-cross-origin" always;
      add_header X-Frame-Options "SAMEORIGIN" always;
      add_header X-Content-Type-Options "nosniff" always;
      add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
    '';
    "mta-sts.${domain}" = {
      enableACME = true;
      forceSSL = true;
      locations."/".root = pkgs.writeTextFile {
        name = "mta-sts.txt";
        text = ''
          version: STSv1
          mode: enforce
          mx: ${stalwartDomain}
          max_age: 86400
        '';
        destination = "/.well-known/mta-sts.txt";
      };
    };
  };

  security.acme.certs.${stalwartDomain} = {
    # Keep a stable private key for TLSA records (DANE)
    # https://community.letsencrypt.org/t/please-avoid-3-0-1-and-3-0-2-dane-tlsa-records-with-le-certificates/7022/14
    # extraLegoRenewFlags = [ "--reuse-key" ];
    # Restart Stalwart to apply new certificates
    reloadServices = [ "stalwart-mail.service" ];
  };

  # services.restic = {
  #   backupPrepareCommand = ''
  #     ${pkgs.coreutils}/bin/install -b -m 700 -d /tmp/stalwart-db-secondary /tmp/stalwart-db-backup
  #     ${lib.getExe' rocksdb.tools "ldb"} --db=${dataDir}/db --secondary_path=/tmp/stalwart-db-secondary backup --backup_dir=/tmp/stalwart-db-backup
  #   '';
  #   backupCleanupCommand = ''
  #     rm -rf /tmp/stalwart-db-secondary
  #     rm -rf /tmp/stalwart-db-backup
  #   '';
  #   paths = [
  #     "/tmp/stalwart-db-backup"
  #     "${dataDir}/blobs"
  #   ];
  # };
}

