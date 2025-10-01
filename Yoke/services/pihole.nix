{ config, pkgs, lib, inputs, ... }: {
  services.pihole-web = {
    enable = true;
    ports = [ 168 ];
  };
  networking.firewall.allowedTCPPorts = [ 168 ];
  networking.firewall.allowedUDPPorts = [ 168 ];
}
