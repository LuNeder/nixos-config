{ config, pkgs, lib, inputs, ... }: {
  services.readeck = { 
    enable = true;
    settings = {
      main = {
        data_directory = "/mnt/pool1/Readeck";
      };
      server = {
        host = "::";
        port = 5678;
      };
    };
    environmentFile = config.sops.templates."readeckenv".path;
  };
  
  networking.firewall.allowedTCPPorts = [ config.services.readeck.settings.server.port ];
  networking.firewall.allowedUDPPorts = [ config.services.readeck.settings.server.port ];
  
  systemd.services.readeck.serviceConfig.ProtectSystem = lib.mkForce false;
  systemd.services.readeck.serviceConfig.DynamicUser = lib.mkForce false;
  systemd.services.readeck.serviceConfig.User = "readeck";
  systemd.services.readeck.serviceConfig.Group = "readeck";

  users.users.readeck = {
    group = "readeck";
    isSystemUser = true;
  };
  users.groups.readeck = {};

  sops.secrets = {
    readeck_secret.sopsFile = ./secrets.yaml;
  };

  sops.templates."readeckenv" = {
    owner = "readeck";
    group = "readeck";
    content = ''
      READECK_SECRET_KEY = ${config.sops.placeholder.readeck_secret}
    '';
  };
}