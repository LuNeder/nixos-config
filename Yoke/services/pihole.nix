{ config, pkgs, lib, inputs, ... }: {
  services.pihole-web = {
    enable = true;
    ports = [ 168 ];
  };
  networking.firewall.allowedTCPPorts = [ 168 53 ];
  networking.firewall.allowedUDPPorts = [ 168 53 ];

  
  services.pihole-ftl = {
    enable = true;
    openFirewallDNS = true;
    openFirewallDHCP = true;
    queryLogDeleter = { 
      enable = true;
      age = 120;
    };
    lists = [
      {
        url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts";
        # Alternatively, use the file from nixpkgs. Note its contents won't be
        # automatically updated by Pi-hole, as it would with an online URL.
        # url = "file://${pkgs.stevenblack-blocklist}/hosts";
        description = "Steven Black's unified adlist";
      }
    ];
    settings = {
      dns = {
        domainNeeded = false;
        expandHosts = true;
        interface = "eno1";
        listeningMode = "LOCAL";
        upstreams = [ "1.1.1.1" "2606:4700:4700::1111" "9.9.9.11" "2620:fe::11" ];
      };
      dhcp = {
        active = false;
      };
    };
  };

}
