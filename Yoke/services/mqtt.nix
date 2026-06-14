{ config, pkgs, lib, inputs, ... }: {
  services.mosquitto = { 
    enable = true;
    listeners = [
      { 
        settings.allow_anonymous = true;
        acl = [
          "pattern readwrite #"
          "topic readwrite anon/report/#"
          "topic readwrite #"
        ];
      }
    ];
  };
  
  networking.firewall.allowedTCPPorts = [ 1883 ];
  networking.firewall.allowedUDPPorts = [ 1883 ];
}
