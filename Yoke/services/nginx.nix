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

  options.var = with lib.types; {
    fqdn = lib.mkOption { type = str; };
    sslCertificate = lib.mkOption { type = str; };
    sslCertificateKey = lib.mkOption { type = str; };
  };

  config.var = {
    fqdn = "yoke.sereia.gay";
    sslCertificate = "/mnt/pool1/certs/yoke.pem";
    sslCertificateKey = "/mnt/pool1/certs/yoke-key.pem";
  };
}