{ config, pkgs, lib, inputs, ... }: {
  services.zigbee2mqtt = {
    enable = true;
    settings = {
      homeassistant = config.services.home-assistant.enable;
      permit_join = true;
      serial = {
        port = "/dev/serial/by-id/usb-SMLIGHT_SMLIGHT_SLZB-07Mg24_de365e62bd8aef11a9c21fccef8776e9-if00-port0";
      };

    };
  };

}
