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

  # Nextcloud # TODO: Not working
  config.services.nginx.virtualHosts."cloud.${config.var.fqdn}" = lib.mkIf config.var.enablePublicNextcloud {
    forceSSL = true;
    enableACME = true;
    serverAliases = [
      "nuvem.da.sereia.gay"
      "cloud.sereia.gay"
    ];

    locations."/" = {
      proxyPass = "http://100.64.0.9:80";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        client_max_body_size 50G;
      '';
    };
  };

  # Collabora (broken)
  #services.nginx.virtualHosts."collabora.${config.var.fqdn}" = {
  #  forceSSL = true;
  #  enableACME = true;
  #  locations."/" = {
  #    proxyPass = "http://100.64.0.9:40080";
  #    proxyWebsockets = true;
  #    extraConfig = ''
  #      proxy_set_header Host $host;
  #      proxy_set_header X-Real-IP $remote_addr;
  #      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  #      proxy_set_header X-Forwarded-Proto $scheme;
  #    '';
  #  serverAliases = [
  #    "docs.da.sereia.gay"
  #  ];
  #  };
  #};

  # Cryptpad
  config.services.nginx = {
    virtualHosts = {
      # Main Cryptpad domain
      "cryptpad.${config.var.fqdn}" = {
        forceSSL = true;
        enableACME = true;
        serverAliases = [
          "docs.da.sereia.gay"
        ];

        locations."/" = {
          proxyPass = "http://100.64.0.9:3500";
          extraConfig = ''
            # Increase max upload size to match Cryptpad's configured limit
            client_max_body_size 150m;

            # Proxy headers
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
          '';
        };

        # WebSocket endpoint for real-time collaboration
        locations."/cryptpad_websocket" = {
          proxyPass = "http://100.64.0.9:3503";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
          '';
        };
      };

      # Sandbox domain, whatever tf this does
      "sandbox.cryptpad.${config.var.fqdn}" = {
        forceSSL = true;
        enableACME = true;
        serverAliases = [
          "sandbox-docs.da.sereia.gay"
        ];

        locations."/" = {
          proxyPass = "http://100.64.0.9:3500";
          extraConfig = ''
            client_max_body_size 150m;

            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
          '';
        };

        # WebSocket endpoint for sandbox domain
        locations."/cryptpad_websocket" = {
          proxyPass = "http://100.64.0.9:3503";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
          '';
        };
      };
    };
  };

  # Radicale
  config.services.nginx.virtualHosts."agenda.${config.var.fqdn}" = {
    forceSSL = true;
    enableACME = true;
    serverAliases = [
      "agenda.da.sereia.gay"
    ];
    extraConfig = ''
      proxy_set_header  X-Script-Name /;
      proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_pass_header Authorization;
    '';
    locations."/" = {
      proxyPass = "http://100.64.0.9:5232";
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