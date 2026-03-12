{ config, pkgs, lib, inputs, ... }: {
  imports = [ ../../Yoke/services/nextcloud-public.nix ];

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

  config.services.nginx.virtualHosts."photos.${config.var.fqdn}" = {
    forceSSL = true;
    enableACME = true;
    serverAliases = [
      "fotos.da.sereia.gay"
      #"photos.sereia.gay"
    ];
    extraConfig = ''
      client_max_body_size 30M;
    '';
    locations."/" = {
      proxyPass = "http://[::1]:${toString config.services.immich-public-proxy.port}";
    };
  };

  # TODO: Not working
  config.services.nginx.virtualHosts."cloud.${config.var.fqdn}" = lib.mkIf config.var.enablePublicNextcloud {
    forceSSL = true;
    enableACME = true;
    serverAliases = [
      "nuvem.da.sereia.gay"
      "cloud.sereia.gay"
    ];

    locations."/" = {
      proxyPass = "http://100.64.0.9";
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