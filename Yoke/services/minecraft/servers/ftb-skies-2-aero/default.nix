{pkgs, inputs, config, ...}: let
  inherit (inputs.nix-minecraft.lib) collectFilesAt;
  packId = "134";
  versionId = "100497";
  ftbInstaller = pkgs.fetchurl {
    url = "https://github.com/FTBTeam/FTB-Server-Installer/releases/download/v1.0.52/ftb-server-linux-amd64";
    hash = "sha256-GESe9jdgKRNSl4FknjUWzTRT0U41t0nXjwSYEQHsb2E=";
  };

  # Run the dumb fucking installer to get all mods
  modpack = pkgs.runCommand "ftb-skies-2-aero-serverfiles" {
    nativeBuildInputs = [ pkgs.jdk25 ];
    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash = "sha256-V4M5CmzySYMEG4tkV3+J9WAU9ujjDyPyZBBG2wiSCso=";
  } ''
    mkdir -p $out
    cd $out
    
    cp ${ftbInstaller} ./serverinstaller
    chmod +x ./serverinstaller
    
    # Run installer in auto mode, skip Java download (we provide our own)
    ./serverinstaller -auto -no-java -pack ${packId} -version ${versionId}
    
    # Clean up installer artifacts that can make the hash inconsistent
    rm -f serverinstaller
    rm run.sh run.bat
    rm *.log
  '';

  neoForgeVersion = "21_1_250";
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
      level-type = "default";
      generate-structures = true;
      allow-flight = true;
      allow-nether = true;

    };
    operators = import ../../ops.nix;

    files = {
      datapacks = "${modpack}/datapacks";
      config = "${modpack}/config";
      defaultconfigs = "${modpack}/defaultconfigs";
      kubejs = "${modpack}/kubejs";
      configureddefaults = "${modpack}/configureddefaults";
      "default-server.properties" = "${modpack}/default-server.properties";
      resourcepacks = "${modpack}/resourcepacks";
      shaderpacks = "${modpack}/shaderpacks";
      ftbteambases = "${modpack}/ftbteambases";
      libraries = "${modpack}/libraries";
      "config/proxy-compatible-forge.toml" = config.sops.templates."proxy-compatible-forge".path;
    };
    
    symlinks = collectFilesAt modpack "mods" // {
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

  sops.templates."proxy-compatible-forge" = {
    owner = "minecraft";
    group = "minecraft";
    content = /* toml */ ''
      #Config version, DO NOT CHANGE THIS
      version = 2.0

      #Player Info Forwarding Settings
      [forwarding]
      	#The type of forwarding to use
      	#Allowed Values: LEGACY, BUNGEEGUARD, MODERN
      	mode = "LEGACY"
      	#Enable or disable player info forwarding. Changing this setting requires a server restart.
      	enabled = true
      	#The forwarding secret shared with the proxy
      	#secret = "${config.sops.placeholder.velocity-fwd}"
      	#A list of approved proxy hostnames or IP addresses. If the connecting proxy's hostname or IP isn't in this list, the player will be disconnected. Leave empty to allow all.
      	approvedProxyHosts = []
        
      #CrossStitch Settings - For Wrapping Modded Command Arguments
      [crossStitch]
      	#Enable or disable CrossStitch support. Changing this setting requires a server restart.
      	enabled = true
      	#Add any incompatible modded or vanilla command argument types here
      	forceWrappedArguments = []
      	#Force wrap vanilla command argument types. Useful for when the above setting gets a bit excessive.
      	forceWrapVanillaArguments = false

      #Debug Settings
      [debug]
      	#Enable or disable debug mode.
      	enabled = false
      	#List of mixins to disable. Use the Mixin's name and prefix it with it's partial or full package name.
      	disabledMixins = []
        
      #Advanced Settings
      [advanced]
      	#Overrides the modern forwarding version decided by PCF. Change it to "MODERN_DEFAULT" if you encounter chat-signing issues. Changing this setting requires a server restart.
      	#Allowed Values: NO_OVERRIDE, MODERN_DEFAULT, MODERN_FORWARDING_WITH_KEY, MODERN_FORWARDING_WITH_KEY_V2, MODERN_LAZY_SESSION
      	modernForwardingVersion = "NO_OVERRIDE"

    '';
  };
}
