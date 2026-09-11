{
  pkgs,
  config,
  ...
}: let
  servers = config.services.minecraft-servers.servers;
  cfg = servers.proxy;
  proxyFlags = memory: "-Xms${memory} -Xmx${memory} -XX:+UseG1GC -XX:G1HeapRegionSize=4M -XX:+UnlockExperimentalVMOptions -XX:+ParallelRefProcEnabled -XX:+AlwaysPreTouch -XX:MaxInlineLevel=15";
in {
  imports = [
    ./librelogin.nix
    ./luckperms.nix
    ./fallbackserver.nix
    ./huskchat.nix # TODO: Discontinued, find alternative
    ./velocitab.nix

    ./geyser.nix
  ];

  networking.firewall = {
    allowedTCPPorts = [cfg.serverProperties.server-port];
    allowedUDPPorts = [cfg.serverProperties.server-port];
  };

  services.minecraft-servers.servers.proxy = {
    enable = true;

    enableReload = true;
    stopCommand = "end";
    extraReload = ''
      echo 'velocity reload' > /run/minecraft/proxy.stdin
    '';

    serverProperties = {
      server-ip = "0.0.0.0";
      server-port = 25565;
      online-mode = true;
      motd = "Luana the Mermaid's Server";
    };

    package = pkgs.velocityServers.velocity.override {
      jre_headless = pkgs.temurin-jre-bin-25;
    }; # Latest build
    jvmOpts = proxyFlags "1G";

    files = {
      "velocity.toml".value = {
        inherit (cfg.serverProperties) online-mode;
        config-version = "2.9";
        bind = "${cfg.serverProperties.server-ip}:${toString cfg.serverProperties.server-port}";
        motd = "<#09add3>${cfg.serverProperties.motd}";
        player-info-forwarding-mode = "MODERN";
        forwarding-secret-file = config.sops.secrets.velocity-fwd.path;

        servers = let
          mkIp = server: "localhost:${toString server.serverProperties.server-port}";
        in {
          limbo = mkIp servers.limbo;
          auth = mkIp servers.limbo;
          ftb-skies-2 = mkIp servers.ftb-skies-2;
          try = ["limbo" "ftb-skies-2"];
        };

        forced-hosts = {
          "aero.minecraaft.yoke.sereia.gay" = ["ftb-skies-2"];
        };

        ping-passthrough = {
          version = false;
          players = false;
          description = false;
          favicon = false;
          modinfo = true;   # passes the mod list from the backend to clients
        };

        query = {
          enabled = true;
          port = cfg.serverProperties.server-port;
        };

        advanced = {
          login-ratelimit = 500;
        };
      };
      #"lang/messages.properties" = ./messages.properties;
      #"plugins/ambassador/Ambassador.toml".value = {
      #  config-version = "2.1";
      #  bypass-registry-checks = true;
      #  enable-kick-reset = true;
      #  reconnect-message = "&ePor favor, reconecte.";
      #};
    };
    symlinks = {
      #"plugins/OwoVelocityPlugin.jar" = pkgs.fetchurl rec {
      #  pname = "OwoVelocityPlugin";
      #  version = "0.1.2";
      #  url = "https://github.com/wisp-forest/owo-velocity-plugin/releases/download/${version}/${pname}.jar";
      #  hash = "sha256-aiAlYdJV2tCxaCMWv9S0Opn29aMGHVyPiJ00ePe1CDw=";
      #};
      #"plugins/Ambassador-Velocity.jar" = pkgs.fetchurl rec {
      #  pname = "Ambassador";
      #  version = "1.4.5";
      #  url = "https://github.com/adde0109/Ambassador/releases/download/v${version}/Ambassador-Velocity-${version}-all.jar";
      #  hash = "sha256-fFemScOUhnLL7zWjuqj3OwRqxQnqj/pu4wCIkNNvLBc=";
      #};
    };
  };

  sops.secrets.velocity-fwd = {
    owner = "minecraft";
    group = "minecraft";
    mode = "0440";
    # nix run nixpkgs#openssl -- rand -hex 32
    sopsFile = ../../secrets.yaml;
  };
}
