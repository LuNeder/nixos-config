{ config, pkgs, lib, inputs, ... }: {
  config.services.nginx = {
    enable = true;
    enableReload = true;
    recommendedTlsSettings = true;
    recommendedProxySettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    clientMaxBodySize = "300m";
  };

  config.networking.firewall.allowedTCPPorts = [ 80 443 ];

  config.services.nginx.virtualHosts."_" = {
    forceSSL = true;
    sslCertificate = "${config.var.sslCertificate}";
    sslCertificateKey = "${config.var.sslCertificateKey}";
    extraConfig = ''
      return 444;
    '';
  };

  options.var = with lib.types; {
    fqdn = lib.mkOption { type = str; };
    sslCertificate = lib.mkOption { type = path; };
    sslCertificateKey = lib.mkOption { type = str; };
  };

  config.var = {
    fqdn = "yoke.sereia.gay";
    sslCertificate = ../yoke+11.pem;
    sslCertificateKey = "/mnt/pool1/certs/yoke+11-key.pem";
  };
}