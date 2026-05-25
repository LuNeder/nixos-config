{ config, pkgs, lib, inputs, ... }: let
  port = 5232;
in {
  services.radicale = {
    enable = true;
    user = "radicale";
    group = "radicale";
    settings = {
      server = {
        hosts = [ "0.0.0.0:${toString port}" "[::]:${toString port}" ];
        max_connections = 0;
      };
      auth = {
        type = "htpasswd";
        htpasswd_filename = "/mnt/pool1/radicale/users";
        htpasswd_encryption = "autodetect";
        cache_logins = true;
        delay = 15;
      };
      storage = {
        filesystem_folder = "/mnt/pool1/radicale/collections";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ port ];
  networking.firewall.allowedUDPPorts = [ port ];

  services.nginx.virtualHosts."agenda.${config.var.fqdn}" = {
    forceSSL = true;
    sslCertificate = "${config.var.sslCertificate}";
    sslCertificateKey = "${config.var.sslCertificateKey}";
    extraConfig = ''
      proxy_set_header  X-Script-Name /;
      proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_pass_header Authorization;
    '';
    locations."/".proxyPass = "http://[::1]:${toString port}";
  };
}