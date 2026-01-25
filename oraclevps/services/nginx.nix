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
    forceSSL = false;
    extraConfig = ''
      return 444;
    '';
  };

  config.services.nginx.virtualHosts."ask.${config.var.fqdn}" = {
    forceSSL = true;
    enableACME = true;
    serverAliases = [
      "pergunte.pra.sereia.gay"
      "ask.sereia.gay"
    ];
    extraConfig = ''
      client_max_body_size 30M;
    '';
    locations."/" = {
      proxyPass = "http://100.64.0.9:8220";
    };
  };

  # Enable acme for usage with nginx vhosts
  config.security.acme = {
    defaults.email = "luana@luana.dev.br";
    acceptTerms = true;
  };

  options.var = with lib.types; {
    fqdn = lib.mkOption { type = str; };
  };

  config.var = {
    fqdn = "rp.sereia.gay";
  };
}