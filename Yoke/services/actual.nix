{ config, pkgs, lib, inputs, ... }: {
  services.actual = {
    enable = true;
    openFirewall = true;
    user = "actual";
    group = "budgetfiles";
    settings = {
      port = 7000;
      dataDir = "/mnt/pool1/Finances/actual-budget";
      https = {
        # Set via nginx
        # key = "${config.var.sslCertificateKey}";
        # cert = "${config.var.sslCertificate}";
      };
    };
  };

  users.users.actual = {
    group = config.services.actual.group;
    home = config.services.actual.settings.dataDir;
    isSystemUser = true;
  };

  services.nginx.virtualHosts."actual.${config.var.fqdn}" = {
    forceSSL = true;
    sslCertificate = "${config.var.sslCertificate}";
    sslCertificateKey = "${config.var.sslCertificateKey}";
    extraConfig = ''
      client_max_body_size 30M;
    '';
    locations."/".proxyPass = "http://[::1]:${toString config.services.actual.settings.port}";
  };
}
