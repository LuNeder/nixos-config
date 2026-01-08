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
      "webostv"
      "http"
      "api"
      "climate"
      "sensor"
      "webhook"
      "template"
      "zha"
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
        external_url = "https://ha.${config.var.fqdn}";
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

      input_boolean = {
        homekit_sensors_update = {
          name = "Collection of HomeKit Sensors";
          initial = "off";
        };
      };

      http = {
        use_x_forwarded_for = true;
        trusted_proxies = [
          "::1"
        ];
        # TODO: needed, but breaks http and does not fix https on sereia.gay
        #ssl_certificate = "${config.var.sslCertificate}";
        #ssl_key = "${config.var.sslCertificateKey}";
        cors_allowed_origins = [
          "https://ha.${config.var.fqdn}"
          "https://100.64.0.9"
          "https://192.168.15.9"
        ];
      };
      api = {};

      websocket_api = {};

      template = [ 
        {
          trigger = [
            {
              trigger = "webhook";
              webhook_id = "!include ./homepod-temphum-webhook.yaml";
            }
          ];
        }
        { 
          sensor = [
          {
            name = "Umidade Relativa do Ar";
            state = "{{ trigger.json.humidity }}";
            unique_id = "90909090";
            device_class = "humidity";
            state_class = "measurement";
          }
          {
            name = "Temperatura Casa";
            state = "{{ trigger.json.temperature }}";
            unique_id = "24242424";
            device_class = "temperature";
            state_class = "measurement";
          }
          ];
        } 
      ];

      automation = "!include automations.yaml"; # It seems I need to manually create this, content being just  "[]" (without the quotes)

      "automation homepodSensors" = [
        {
          alias = "Homekit - Sensor Collection";
          description = "Processes temperature and humidity data from the HomePod Mini";
          trigger = [
            {
              platform = "time_pattern";
              minutes = "/2";
              id = "time";
            }
          ];
          action = [
            {
              service = "input_boolean.turn_on";
              target.entity_id = "input_boolean.homekit_sensors_update";
            }
            {
              delay = ''00:00:05'';
            }
            {
              service = "input_boolean.turn_off";
              target.entity_id = "input_boolean.homekit_sensors_update";
            }
          ];
          mode = "single";
        }
      ];
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
    homepod-temphum-webhook = {
      sopsFile = ../secrets.yaml;
      path = "${config.services.home-assistant.configDir}/homepod-temphum-webhook.yaml";
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

  # TODO: BROKEN, Fix https and sereia.gay
  services.nginx.virtualHosts."ha.${config.var.fqdn}" = {
    forceSSL = false;
    sslCertificate = "${config.var.sslCertificate}";
    sslCertificateKey = "${config.var.sslCertificateKey}";
    extraConfig = ''
      client_max_body_size 30M;
      proxy_set_header    Upgrade     $http_upgrade;
      proxy_set_header    Connection  "upgrade";
    '';
    locations."/".proxyPass = "http://[::1]:${toString config.services.home-assistant.port}";
  };
}

