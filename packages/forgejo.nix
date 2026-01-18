{ lib, pkgs, config, ... }:

let
  domain = config.vars.domain;
  email = config.vars.email;

  cfg = config.services.forgejo;
  srv = cfg.settings.server;
in
{
  services.forgejo = {
    enable = true;
    database.type = "postgres";
    lfs.enable = true; # Enable support for Git Large File Storage
    settings = {
      server = {
        DOMAIN = "git.${domain}";
        ROOT_URL = "https://${srv.DOMAIN}/";
        HTTP_PORT = 3000;
        SSH_PORT = 6968;
      };

      # You can temporarily allow registration to create an admin user.
      service.DISABLE_REGISTRATION = true;

      # Add support for actions, based on act: https://github.com/nektos/act
      actions = {
        ENABLED = true;
        DEFAULT_ACTIONS_URL = "github";
      };

      # Sending emails is completely optional
      mailer = {
        ENABLED = true;
        SMTP_ADDR = "mail.${domain}";
        FROM = "no-reply@${domain}";
        USER = "no-reply@${domain}";
      };
    };

    secrets = {
      mailer.PASSWD = "/etc/env/forgejo/smtp-password";
    };
  };

  # Manage users declaratively
  systemd.services.forgejo.preStart = let
    adminCmd = "${lib.getExe cfg.package} admin user";
    pwdPath = "/etc/env/forgejo/adminuser-password";
    user = "LukaDeka";
  in ''
    ${adminCmd} create --admin --email "${email}" --username ${user} --password "$(tr -d '\n' < ${pwdPath})" || true
    ## uncomment this line to change an admin user which was already created
    # ${adminCmd} change-password --username ${user} --password "$(tr -d '\n' < ${pwdPath})" || true
  '';

  # Allow the forgejo user to log in via SSH
  users.users.forgejo = {
    openssh.authorizedKeys.keys = config.users.users."${config.vars.username}".openssh.authorizedKeys.keys;
    # openssh.authorizedKeys.keys = [
        # "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM/4F45h/xkq+MIRDzhHqDm5uWM4KTpYi3Tv/DtSo28t luka@gram" # EOS
        # "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF7OvW6MffYFshZyarEaWvWjEmhodn/P+NLcnqbbMpma luka@conway"
        # "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFxw+URmM/WpNRRwJpBgLL6EmXuYxA3SKItQZZyjXxw6 luka@berlin"
        # "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIT+vMzh2ngUeqnVJS8Zl1m1HQMBkDOqoGdoARPyJgDM u0_a380@localhost" # S
      # ];
    # };
  };

  services.nginx = {
    virtualHosts.${srv.DOMAIN} = {
      forceSSL = true;
      enableACME = true;
      extraConfig = ''
        client_max_body_size 512M;
      '';
      locations."/".proxyPass = "http://localhost:${toString srv.HTTP_PORT}";
    };
  };
}
