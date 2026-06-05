{ config, pkgs, lib, inputs, ... }: let
  port = 6065;
in {
  services.webdav = {
    enable = true;
    user = "webdav";
    group = "personalfiles";
    environmentFile = config.sops.templates."webdav-env".path;
    settings = {
      address = "0.0.0.0";
      port = port;
      tls = true; # Neeeded by SeedVault for some dumb reason
      cert = "${config.var.sslCertificate}";
      key = "${config.var.sslCertificateKey}";
      directory = "/mnt/pool1/PersonalFiles/";
      permissions = "RC";
      users = [
        {
          username = "seedvault";
          password = "{env}ENV_SEEDVAULT_PASSWORD";
          directory = "/mnt/pool1/PersonalFiles/Documentos/Android-Backups/";
          permissions = "CRUD";
        }
        {
          username = "easysync";
          password = "{env}ENV_EASYSYNC_PASSWORD";
          directory = "/mnt/pool1/PersonalFiles/Media/Android-EasySync/";
          permissions = "CRUD";
        }
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [ port ];
  networking.firewall.allowedUDPPorts = [ port ];

  sops.secrets = {
    webdav-seedvault-pass.sopsFile = ../secrets.yaml;
    webdav-easysync-pass.sopsFile = ../secrets.yaml;
  };
  sops.templates."webdav-env" = {
    owner = config.services.webdav.user;
    group = config.services.webdav.group;
    content = ''
      ENV_SEEDVAULT_PASSWORD='${config.sops.placeholder.webdav-seedvault-pass}'
      ENV_EASYSYNC_PASSWORD='${config.sops.placeholder.webdav-easysync-pass}'
    '';
  };
}