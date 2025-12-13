{ config, pkgs, lib, inputs, ... }: {
  services.actual = {
    enable = true;
    openFirewall = true;
    user = "actual";
    group = "budgetfiles";
    settings = {
      port = 7000;
      dataDir = "/mnt/pool1/Finances/actual-budget";
      https = {
        key = "/mnt/pool1/Finances/actual-budget/yoke-key.pem";
        cert = "/mnt/pool1/Finances/actual-budget/yoke.pem";
      };
    };
  };

    users.users.actual = {
      group = config.services.actual.group;
      home = config.services.actual.settings.dataDir;
      isSystemUser = true;
    };
}
