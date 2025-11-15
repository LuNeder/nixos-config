{ config, pkgs, lib, ... }: {

  imports = [
    ./octoprint.nix
    ./webcam.nix
  ];
  
  # Klipper
  services.klipper = {
    enable = true;
    configFile = ./printer-creality-ender5-2019.cfg;
    mutableConfig = false;
  };

  # UI for touchscreen
  environment.systemPackages = [
    pkgs.klipperscreen
  ];

  # Fluidd webUI
  services.fluidd = {
    enable = true;
  };

  # Increase max upload size for uploading .gcode files
  services.nginx.clientMaxBodySize = "1000m";

  # Backend controller for Fluidd
  services.moonraker = {
    enable = true;
    address = "0.0.0.0";
    port = 7125;
    user = "root";
    group = "root";
    settings = {
      octoprint_compat = { };
      history = { };
      authorization = {
        force_logins = true;
        cors_domains = [
          "192.168.15.*"
          "100.64.0.*"
          "*.local"
          "*.lan"
          "*://app.fluidd.xyz"
          "*://my.mainsail.xyz"
        ];
        trusted_clients = [
          "10.0.0.0/8"
          "127.0.0.0/8"
          "169.254.0.0/16"
          "172.16.0.0/12"
          "100.64.0.0/12"
          "192.168.15.0/24"
          "FE80::/10"
          "::1/128"
        ];
      };
    };
  };

  # Firewall
  networking.firewall.allowedTCPPorts = [ 80 config.services.moonraker.port ];
  networking.firewall.allowedUDPPorts = [ 80 config.services.moonraker.port ];

}