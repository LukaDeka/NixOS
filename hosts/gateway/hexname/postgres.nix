{ ... }:

{
  # Postgres is already enabled because of the rest of the config.
  # This file only "ensures" it is always enabled
  services.postgresql = {
    enable = true;
  };
}

