{ config, pkgs, lib, inputs, ... }: {
  services.mosquitto = { 
    enable = true;
    listeners = [
      { 
        settings.allow_anonymous = true;
      }
    ];
  };
  
  networking.firewall.allowedTCPPorts = [ 1883 ];
  networking.firewall.allowedUDPPorts = [ 1883 ];
}