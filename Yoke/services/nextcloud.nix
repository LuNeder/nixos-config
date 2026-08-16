{ config, pkgs, lib, inputs, ... }: let
  hostName = "cloud.${config.var.fqdn}";
  internalDomains = [
    "cloud.${config.var.fqdn}"
    "192.168.15.9"
    "100.64.0.9"
    "yoke"
    "169.254.6.116" # Thunderbolt (have to figure out how to set static without breaing when disconnected)
    "yoke.fairy-scylla.ts.net"
    hostName
  ];
  externalDomains = [
    "nuvem.da.sereia.gay"
    "cloud.sereia.gay"
    "cloud.rp.sereia.gay"
  ];
in {
  imports = [ ./nextcloud-public.nix ];
  services = {
    nextcloud = {
      inherit hostName;

      package = pkgs.nextcloud34;
      enable = true;

      https = true;

      datadir = config.services.nextcloud.home;
      home = "/mnt/pool1/nextcloud";

      settings = {
        trusted_domains = internalDomains ++ (if config.var.enablePublicNextcloud then externalDomains else []);
        trusted_proxies = [ "100.64.0.33" ];
      };
      
      database.createLocally = true;

      config = {
        adminpassFile = config.sops.secrets.nextcloud-password.path;
        dbtype = "pgsql";
      };

      extraApps = {
        inherit (config.services.nextcloud.package.packages.apps) contacts calendar 
        tasks notes forms memories previewgenerator;
        #duplicatefinder = pkgs.fetchNextcloudApp { # https://github.com/eldertek/duplicatefinder/pull/169
        #  url = "https://github.com/eldertek/duplicatefinder/releases/download/v1.7.3/duplicatefinder-v1.7.3.tar.gz";
        #  sha256 = "sha256-VoA0jHS2Nkfz/c1UKSKFTdzFGbXV2/chhWy9vbGYOSc=";
        #  license = "agpl3Only";
        #};
        eurooffice = pkgs.fetchNextcloudApp {
          url = "https://github.com/nextcloud-releases/eurooffice/releases/download/v11.0.2/eurooffice-v11.0.2.tar.gz";
          sha256 = "sha256-xqKBv0WDIeGulXTe4JGcfNsLn4OGXigt6+wbBoMrh84=";
          license = "agpl3Only";
        };
      };
      extraAppsEnable = true;
      
      appstoreEnable = true;
      
      maxUploadSize = "2048G";
   };

    postgresql = {
      ensureDatabases = ["nextcloud"];
      ensureUsers = [
        {
          name = "nextcloud";
          ensureDBOwnership = true;
        }
      ];
    };

    nginx.virtualHosts."${hostName}" = {
      #listen = [{
      #  addr = "0.0.0.0";
      #  port = 80;
      #}];
      forceSSL = true; # tunnel, but false breaks shit
      sslCertificate = "${config.var.sslCertificate}";
      sslCertificateKey = "${config.var.sslCertificateKey}";
      enableACME = false;
      serverAliases = internalDomains;
      locations."/" = {
        #root = config.services.nextcloud.home;
        #extraConfig = '' # TODO: breaks shit
        #  fastcgi_split_path_info ^(.+\.php)(/.+)$;
        #  fastcgi_pass unix:/run/phpfpm/nextcloud.sock;
        #  include ${pkgs.nginx}/conf/fastcgi_params;
        #  include ${pkgs.nginx}/conf/fastcgi.conf;
        #'';
      };
    };
  };

  users.users.nextcloud.extraGroups = [ "personalfiles" "budgetfiles" "viddownload" ];

  sops.secrets.nextcloud-password = {
    owner = "nextcloud";
    group = "nextcloud";
    sopsFile = ../secrets.yaml;
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
