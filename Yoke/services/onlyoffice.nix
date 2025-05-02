{config, ...}: {
  boot.kernel.sysctl = {
    # Onlyoffice requires non-privileged users namespaces
    "kernel.unprivileged_userns_clone" = 1;
  };
  services = {
    onlyoffice = {
      enable = true;
      hostname = "localhost";
      # Autenticação via unix socket
      postgresName = "onlyoffice";
      postgresUser = "onlyoffice";
      port = 8001;
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
  };

  users.groups.onlyoffice = {
    members = ["nginx" "nextcloud"];
  };

#  sops.secrets.onlyoffice-secret = {
#    owner = "onlyoffice";
#    group = "onlyoffice";
#    sopsFile = ../secrets.yaml;
#  };
}