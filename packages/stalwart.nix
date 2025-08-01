{ config, ... }:

let
  domain = config.vars.domain;
  email = config.vars.email;
in
{
  services.stalwart-mail = {
    enable = true;
    package = pkgs.stalwart-mail;
    openFirewall = true;

    settings = {
      tracer.stdout = {
        # Do not use the built-in journal tracer, as it shows much less
        # auxiliary information for the same loglevel
        type = "stdout";
        level = "info";
        ansi = false; # no color markers to journald
        enable = true;
      };

      store.db = {
        type = "sqlite";
        path = "${dataDir}/database.sqlite3";
      };

      server = {
        hostname = "mail.${domain}";
        tls = {
          enable = true;
          implicit = true;
        };
        listener = {
          smtp = {
            protocol = "smtp";
            bind = "[::]:25";
          };
          submissions = {
            bind = "[::]:465";
            protocol = "smtp";
          };
          imaps = {
            bind = "[::]:993";
            protocol = "imap";
          };
          jmap = {
            bind = "[::]:8080";
            url = "https://mail.${domain}";
            protocol = "jmap";
          };
          management = {
            bind = [ "127.0.0.1:8080" ];
            protocol = "http";
          };
        };
      };


      lookup.default = {
        hostname = "mail.${domain}";
        domain = domain;
      };

      acme."letsencrypt" = {
        directory = "https://acme-v02.api.letsencrypt.org/directory";
        challenge = "dns-01";
        contact = email;
        domains = [ domain "mail.${domain}" ];
        provider = "cloudflare";
        secret = "%{file:/etc/env/stalwart/acme-secret}%";
      };
      session.auth = {
        mechanisms = "[plain]";
        directory = "'in-memory'";
      };
      storage.directory = "in-memory";
      session.rcpt.directory = "'in-memory'";
      queue.outbound.next-hop = "'local'";
      directory."imap".lookup.domains = [ domain ];
      directory."in-memory" = {
        type = "memory";
        principals = [
          {
            class = "individual";
            name = "Main user";
            secret = "%{file:/etc/env/stalwart/mail-pw1}%";
            email = [ "me@${domain}" ];
          }
          {
            class = "individual";
            name = "postmaster";
            secret = "%{file:/etc/env/stalwart/mail-pw1}%";
            email = [ "postmaster@${domain}" ];
          }
        ];
        address-map = [
          {
            source = [ "*@${domain}" ];
            destination = [ "me@${domain}" ];
          }
          {
            source = [
              "info@${domain}"
              "support@${domain}"
              "sales@${domain}"
              "contact@${domain}"
              "marketing@${domain}"
            ];
            action = "reject";
          }
        ];
      };
      authentication.fallback-admin = {
        user = "admin";
        secret = "%{file:/etc/env/stalwart/admin-pw}%";
      };
    };
  };

  services.caddy = {
    enable = true;
    virtualHosts = {
      "mail-admin.${domain}" = {
        extraConfig = ''
          reverse_proxy http://127.0.0.1:8080
        '';
        serverAliases = [
          "mta-sts.${domain}"
          "autoconfig.${domain}"
          "autodiscover.${domain}"
          "mail.${domain}"
        ];
      };
    };
  };
}

