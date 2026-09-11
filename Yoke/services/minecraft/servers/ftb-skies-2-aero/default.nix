{pkgs, inputs, config, ...}: let
  inherit (inputs.nix-minecraft.lib) collectFilesAt;
  modpack = pkgs.fetchzip {
    url = "https://www.curseforge.com/api/v1/mods/1611302/files/8839203/download";
    hash = "sha256-zD41lpl80y/cyDuQQne9BbXlP5t6s7MKg2sE+K7ZOkI=";
    extension = "zip";
    stripRoot = false;
    postFetch = "mv $out/overrides/* $out/";
  };
  neoForgeVersion = "21_1_77";
  neoForgeServer = pkgs.minecraftServers."neoforge-1_21_1-${neoForgeVersion}".override {
    jre_headless = pkgs.temurin-jre-bin-21;
  };
in {
  services.minecraft-servers.servers.ftb-skies-2 = {
    enable = true;
    enableReload = true;
    package = neoForgeServer;
    jvmOpts = (import ../../aikar-flags.nix) "8G";
    whitelist = import ../../whitelist.nix;
    serverProperties = {
      server-ip = "0.0.0.0";
      server-port = 25575;
      online-mode = false;
      motd = "FTB Skies 2: Aero";
      difficulty = "normal";
      max-tick-time = -1;
      view-distance = 10;
      simulation-distance = 8;
    };
    operators = import ../../ops.nix;

    files = {
      config = "${modpack}/config";
      defaultconfigs = "${modpack}/defaultconfigs";
      kubejs = "${modpack}/kubejs";
      configureddefaults = "${modpack}/configureddefaults";
      "default-server.properties" = "${modpack}/default-server.properties";
      resourcepacks = "${modpack}/resourcepacks";
      shaderpacks = "${modpack}/shaderpacks";

      "config/proxy-compatible-forge.toml".value = {
        forwarding = {
          mode = "MODERN";
          #secret = "@VELOCITY_FWD@"; # does not get env vars, maybe make this file with sops if I want modern?
        };
      };
    };
    
    symlinks = collectFilesAt modpack "mods" // collectFilesAt modpack "datapacks" // {
      "server-icon.png" = "${modpack}/server-icon.png";

      "mods/proxy-compatible-forge-1.3.1.jar" = pkgs.fetchurl rec {
        pname = "Proxy-Compatible-Forge";
        version = "1.3.1";
        url = "https://github.com/adde0109/Proxy-Compatible-Forge/releases/download/v${version}/proxy-compatible-forge-${version}.jar";
        hash = "sha256-6lQa/2J2lw2YUGllyOcb1K1zKUUvYxsvResI7epCUnE=";
      };

      "mods/ftb-library-neoforge-2101.1.36.jar" = pkgs.fetchurl rec {
        pname = "ftb-library-neoforge";
        url = "https://www.curseforge.com/api/v1/mods/404465/files/8858846/download";
        hash = "sha256-USJXnk1V13BX6YoUA7YAbd6V05eXb8PC7n3QZnR8aW8=";
      };

      "mods/architectury-13.0.11-neoforge.jar" = pkgs.fetchurl rec {
        pname = "architectury-neoforge";
        url = "https://cdn.modrinth.com/data/lhGA9TYQ/versions/1IiqEQGl/architectury-13.0.11-neoforge.jar?mr_download_reason=standalone&mr_game_version=1.21.1&mr_loader=neoforge";
        hash = "sha256-nMkvLAlTP8VILGD5k72JHGVaDjK2NwN83LfCsjre3us=";
      };
    };
  };
}
