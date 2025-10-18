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
          "100.64.0.9"
          "yoke.fairy-scylla.ts.net"
          "yoke"
          "169.254.6.116" # Thunderbolt (have to figure out how to set static without breaing when disconnected)
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
        duplicatefinder = pkgs.fetchNextcloudApp {
          url = "https://github.com/eldertek/duplicatefinder/releases/download/v1.7.3/duplicatefinder-v1.7.3.tar.gz";
          sha256 = "sha256-VoA0jHS2Nkfz/c1UKSKFTdzFGbXV2/chhWy9vbGYOSc=";
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
  };

  sops.secrets.nextcloud-password = {
    owner = "nextcloud";
    group = "nextcloud";
    sopsFile = ../secrets.yaml;
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
