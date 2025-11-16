{ config, pkgs, lib, inputs, ... }: {
  services.actual = {
    enable = true;
    openFirewall = true;
    settings = {
      port = 7000;
      dataDir = "/mnt/pool1/PersonalFiles/Documentos/Finances/actual-budget";
      https = {
        key = "/mnt/pool1/PersonalFiles/Documentos/Finances/actual-budget/yoke-key.pem";
        cert = "/mnt/pool1/PersonalFiles/Documentos/Finances/actual-budget/yoke.pem";
      };
    };
  };
}