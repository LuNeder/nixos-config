{ config, pkgs, lib, inputs, ... }: {
  services.home-assistant = {
    enable = true;

    openFirewall = true;

    extraComponents = [
      # Components required to complete the onboarding
      "met"
      "radio_browser"
      "shopping_list"
      # Recommended for fast zlib compression
      # https://www.home-assistant.io/integrations/isal
      "isal"
      "analytics"
      "google_translate"

      "wake_on_lan"
      "webdav"
      "apple_tv"
      "homekit"
      "homekit_controller"
      "icloud"
      "roborock"
      "webostv"
    ];

    config = {
      # Includes dependencies for a basic setup
      # https://www.home-assistant.io/integrations/default_config/
      default_config = {};

      homeassistant = {
        name = "Home";
        latitude = "!include ./latitude.yaml";
        longitude = "!include ./longitude.yaml";
        elevation = "!include ./elevation.yaml";
        unit_system = "metric";
        temperature_unit = "C";
        time_zone = config.time.timeZone;
      };

      switch = [
        {
          platform = "wake_on_lan";
          name = "PC de Luana";
          mac = "!include ./pc-mac-address.yaml";
          host = "192.168.15.7";
          turn_off.action = "shell_command.turn_off_pc";
        }
      ];

      shell_command = {
        turn_off_pc =''"${pkgs.writeShellApplication {name = "ssh-poweroff"; text = "${pkgs.openssh}/bin/ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.15.7";}}/bin/ssh-poweroff"'';
      };
    };
  };

  sops.secrets = {
    latitude = {
      sopsFile = ../secrets.yaml;
      path = "${config.services.home-assistant.configDir}/latitude.yaml";
      mode = "0555";
    };
    longitude = {
      sopsFile = ../secrets.yaml;
      path = "${config.services.home-assistant.configDir}/longitude.yaml";
      mode = "0555";
    };
    elevation = {
      sopsFile = ../secrets.yaml;
      path = "${config.services.home-assistant.configDir}/elevation.yaml";
      mode = "0555";
    };
    pc-mac-address = {
      sopsFile = ../secrets.yaml;
      path = "${config.services.home-assistant.configDir}/pc-mac-address.yaml";
      mode = "0555";
    };
  };

  networking.firewall.allowedTCPPorts = [ 
    # HomeKit Bridge  
    21063 21064 5353 
    # Other ports listed as being used by HA (netstat -ln), at least 1 of these also needed by the Bridge
    8123 40000 47831 34041 1900 35698 39446 42277 59682
  ];
  networking.firewall.allowedUDPPorts = [ 
    # HomeKit Bridge  
    21063 21064 5353 
    # Other ports listed as being used by HA (netstat -ln), at least 1 of these also needed by the Bridge
    8123 40000 47831 34041 1900 35698 39446 42277 59682
  ];
}
