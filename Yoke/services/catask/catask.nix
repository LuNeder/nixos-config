{ config, pkgs, lib, inputs, ... }: {
  services.catask = {
    enable = true;
    listenAddress = "[::]";
    port = 8220;
    openFirewall = true;
    dotenvPath = config.sops.templates."cataskenv".path;
  };

    sops.secrets = {
    appsecret.sopsFile = ./secrets.yaml;
    admpass.sopsFile = ./secrets.yaml;

  };
  sops.templates."cataskenv" = {
    owner = config.services.catask.user;
    group = config.services.catask.group;
    content = ''
      DB_HOST = 127.0.0.1
      DB_NAME = catask
      DB_USER = catask
      DB_PORT = 5432
      ADMIN_PASSWORD = '${config.sops.placeholder.admpass}'
      APP_SECRET = ${config.sops.placeholder.appsecret}
    '';
  };
}
