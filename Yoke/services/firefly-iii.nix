{ config, pkgs, lib, inputs, ... }: {
  services.firefly-iii = {
    enable = true;
    dataDir = "/mnt/pool1/PersonalFiles/Documentos/Finances/firefly-iii";
    enableNginx = true;
    virtualHost = "0.0.0.0:7000";

    settings = {
      DB_CONNECTION = "pgsql";
      APP_KEY_FILE = "/mnt/pool1/PersonalFiles/Documentos/Finances/firefly-iii/keyfile.key";
    };
  };

  services.firefly-iii-data-importer = {
    enable = true;
    enableNginx = true;
    virtualHost = "0.0.0.0:7001";
  };

  networking.firewall.allowedTCPPorts = [ 7000 ];
  networking.firewall.allowedUDPPorts = [ 7000 ];
}