{ config, pkgs, lib, inputs, ... }: {
  # imports = [ ./zigbee2mqtt.nix ]; # using zha

  services.home-assistant = {
    enable = true;

    openFirewall = true;

    extraComponents = [
      # Components required to complete the onboarding
      "met"
      "mqtt"
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
      "hardware"
      "homeassistant_hardware"
      "homekit"
      "homekit_controller"
      "icloud"
      # "roborock" # TODO: Broken build
      "vacuum"
      "mqtt_eventstream"
      "mqtt_json"
      "mqtt_room"
      "mqtt_statestream"
      "manual_mqtt"
      "webostv"
      "http"
      "api"
      "climate"
      "sensor"
      "webhook"
      "template"
      "zha"
      "caldav"
      "calendar"

      # Voice Assistant
      "wyoming"       
    ];

    customComponents = [
      pkgs.home-assistant-custom-components.valetudo
    ];

    customLovelaceModules = [
      pkgs.home-assistant-custom-lovelace-modules.valetudo-map-card
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
        external_url = "http://ha.${config.var.fqdn}:8123";
        internal_url = "http://192.168.15.9";
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

      http = {
        use_x_forwarded_for = true;
        trusted_proxies = [
          "::1"
        ];
        # TODO: breaks http
        #ssl_certificate = "${config.var.sslCertificate}";
        #ssl_key = "${config.var.sslCertificateKey}";
        base_url = "http://ha.yoke.sereia.gay:8123";
        cors_allowed_origins = [
          "https://ha.${config.var.fqdn}"
          "https://100.64.0.9"
          "https://192.168.15.9"
        ];
      };

      api = {};

      websocket_api = {};

      automation = "!include automations.yaml"; # It seems I need to manually create this, content being just  "[]" (without the quotes)
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

  networking.firewall.logRefusedPackets = true;
  networking.firewall.allowedTCPPorts = [ 
    # HomeKit Bridge  
    21063 21064 5353 
    # Other ports listed as being used by HA (netstat -ln), at least 1 of these also needed by the Bridge
    8123 40000 47831 34041 1900 35698 39446 42277 59682
    # Audio to HomePod
    554 3689 34754 54751 58448 61691 49458 56477 52107
  ];
  networking.firewall.allowedTCPPortRanges = [
    # Audio to HomePod
    { from = 42000; to = 43000; }
    { from = 30000; to = 65535; }
    #{ from = 8000; to = 9000; }
  ];
  networking.firewall.allowedUDPPorts = [ 
    # HomeKit Bridge  
    21063 21064 5353 
    # Other ports listed as being used by HA (netstat -ln), at least 1 of these also needed by the Bridge
    8123 40000 47831 34041 1900 35698 39446 42277 59682
    # Audio to HomePod
    554 3689 34754 54751 58448 61691 49458 56477 52107
  ];
  networking.firewall.allowedUDPPortRanges = [
    # Audio to HomePod
    { from = 42000; to = 43000; }
    { from = 30000; to = 65535; }
    #{ from = 8000; to = 9000; }
  ];

  # Broken
  #services.nginx.virtualHosts."ha.${config.var.fqdn}" = {
  #  forceSSL = true;
  #  sslCertificate = "${config.var.sslCertificate}";
  #  sslCertificateKey = "${config.var.sslCertificateKey}";
  #  extraConfig = ''
  #    proxy_buffering off;
  #  '';
  #  locations."/" = {
  #    proxyPass = "http://[::1]:${toString config.services.home-assistant.config.http.server_port}";
  #    proxyWebsockets = true;
  #  };
  #};
}

