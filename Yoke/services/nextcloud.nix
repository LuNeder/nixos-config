{ config, pkgs, lib, inputs, ... }: let
  hostName = "localhost";
in {
  services = {
    nextcloud = {
      inherit hostName;

      package = pkgs.nextcloud31;
      enable = true;

      https = false;

      home = "/mnt/pool1/nextcloud";

      settings = {
        trusted_domains = [
          "192.168.15.9"
          "100.95.29.43"
          "yoke.fairy-scylla.ts.net"
          "yoke"
          hostName
        ];
      };
      
      database.createLocally = true;

      config = {
        adminpassFile = config.sops.secrets.nextcloud-password.path;
        dbtype = "pgsql";
      };

      extraApps = {
        inherit (config.services.nextcloud.package.packages.apps) onlyoffice contacts calendar 
        tasks notes forms memories previewgenerator;
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
  };

  sops.secrets.nextcloud-password = {
    owner = "nextcloud";
    group = "nextcloud";
    sopsFile = ../secrets.yaml;
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
