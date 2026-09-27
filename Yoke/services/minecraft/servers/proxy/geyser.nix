{pkgs, ...}: let
  geyserUrl = n: v: b: "https://download.geysermc.org/v2/projects/${n}/versions/${v}/builds/${b}/downloads/velocity";
in {
  networking.firewall = {
    allowedUDPPorts = [19132];
    #extraCommands = let # This would need to go on the public vps
    #  timeSeconds = 60;
    #  maxHits = 5;
    #in
    #  # Block pesky china botnet
    #  "iptables -I INPUT -p udp --dport 19132 -m state --state NEW -m recent --update --seconds ${toString timeSeconds} --hitcount ${toString maxHits} -j DROP";
  };

  services.minecraft-servers.servers.proxy = {
    symlinks = {
      "plugins/Geyser.jar" = pkgs.fetchurl rec {
        pname = "geyser";
        version = "2.11.3";
        url = geyserUrl pname version "1247";
        hash = "sha256-PvZLiv6HeIc8BuVeiac/gQkhR4GrH5ZGNgMaUtLu5hk=";
      };
      "plugins/Floodgate.jar" = pkgs.fetchurl rec {
        pname = "floodgate";
        version = "2.2.5";
        url = geyserUrl pname version "141";
        hash = "sha256-ZJg1Ai3jf/CSVfxibUv+e8KjuSbQew368fUeEr83AB0=";
      };
    };
    files = {
      "plugins/Geyser-Velocity/config.yml".value = {
        server-name = "Server da Luana";
        passthrough-motd = true;
        passthrough-player-counts = true;
        allow-third-party-capes = true;
        auth-type = "floodgate";
      };
    };
  };
}