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

      package = pkgs.nextcloud33;
      enable = true;

      https = true;

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
        inherit (config.services.nextcloud.package.packages.apps) onlyoffice contacts calendar 
        tasks notes forms memories previewgenerator;
        #duplicatefinder = pkgs.fetchNextcloudApp { # https://github.com/eldertek/duplicatefinder/pull/169
        #  url = "https://github.com/eldertek/duplicatefinder/releases/download/v1.7.3/duplicatefinder-v1.7.3.tar.gz";
        #  sha256 = "sha256-VoA0jHS2Nkfz/c1UKSKFTdzFGbXV2/chhWy9vbGYOSc=";
        #  license = "agpl3Only";
        #};
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
      forceSSL = true; # tunnel
      sslCertificate = "${config.var.sslCertificate}";
      sslCertificateKey = "${config.var.sslCertificateKey}";
      serverAliases = internalDomains;
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
