{ config, pkgs, lib, inputs, ... }: {
  services.hledger-web = {
    enable = true;
    port = 7000;
    stateDir = "/mnt/pool1/PersonalFiles/Documentos/Finances/hledger";
    host = "0.0.0.0";
    allow = "edit";
    journalFiles = [
      "hledger.journal"
    ];
  };

  networking.firewall.allowedTCPPorts = [ config.services.hledger-web.port ];
  networking.firewall.allowedUDPPorts = [ config.services.hledger-web.port ];
}