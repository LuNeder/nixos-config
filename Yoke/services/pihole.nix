{ config, pkgs, lib, inputs, ... }: {
  services.pihole-web = {
    enable = true;
    ports = [ 168 ];
  };
  networking.firewall.allowedTCPPorts = [ 168 ];
  networking.firewall.allowedUDPPorts = [ 168 ];

  
  services.pihole-ftl = {
    enable = true;
    openFirewallDNS = true;
    openFirewallDHCP = true;
    queryLogDeleter.enable = true;
  };

}
