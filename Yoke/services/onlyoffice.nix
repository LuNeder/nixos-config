{config, ...}: {
  boot.kernel.sysctl = {
    # Onlyoffice requires non-privileged users namespaces
    "kernel.unprivileged_userns_clone" = 1;
  };
  services.nginx.virtualHosts."localhost".listen = [ { addr = "127.0.0.1"; port = 8987; } ];
  services = {
    onlyoffice = {
      enable = true;
      hostname = "localhost";
      # Autenticação via unix socket
      postgresName = "onlyoffice";
      postgresUser = "onlyoffice";
      port = 8987;
      #jwtSecretFile = config.sops.secrets.onlyoffice-secret.path;
    };
    postgresql = {
      ensureDatabases = ["onlyoffice"];
      ensureUsers = [
        {
          name = "onlyoffice";
          ensureDBOwnership = true;
        }
      ];
    };

    services.nginx.virtualHosts."docs.${config.var.fqdn}" = {
      forceSSL = true;
      sslCertificate = "${config.var.sslCertificate}";
      sslCertificateKey = "${config.var.sslCertificateKey}";
      extraConfig = ''
        client_max_body_size 30M;
      '';
      locations."/".proxyPass = "http://[::1]:${toString config.services.onlyoffice.port}";
    };
  };

  users.groups.onlyoffice = {
    members = [ "nginx" "nextcloud" ];
  };

  users.users.onlyoffice.extraGroups = [ "personalfiles" ];


  #sops.secrets.onlyoffice-secret = {
  #  owner = "onlyoffice";
  #  group = "onlyoffice";
  #  sopsFile = ../secrets.yaml;
  #};
}
