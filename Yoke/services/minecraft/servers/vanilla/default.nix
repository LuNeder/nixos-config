{pkgs, ...}: {
  services.minecraft-servers.servers.vanilla = {
    enable = true;
    enableReload = true;
    whitelist = import ../../whitelist.nix;
    operators = import ../../ops.nix;
    package = pkgs.paperServers.paper-26_3;
    jvmOpts = ((import ../../aikar-flags.nix) "2G") + "-Dpaper.disableChannelLimit=true";
    serverProperties = {
      server-port = 25571;
      online-mode = false;
      enable-rcon = false;
      enforce-secure-profiles = false;
      motd = "The Gay Mermaid's Vanilla+ Server";
    };
    files = {
      "config/paper-global.yml".value = {
        proxies.bungee-cord = {
          online-mode = true;
          proxy-protocol = true;
        };
      };
      "bukkit.yml".value = {
        settings.shutdown-message = "Servidor fechado (provavelmente reiniciando).";
      };
      "spigot.yml".value = {
        settings.bungeecord = true; # Legacy Velocity proxying
        messages = {
          whitelist = "Você não está na whitelist!";
          unknown-command = "Comando desconhecido.";
          restart = "Servidor reiniciando.";
        };
      };
      "plugins/ViaVersion/config.yml".value = {
        checkforupdates = false;
      };
      "plugins/LuckPerms/config.yml".value = {
        server = "vanilla";
        storage-method = "mysql";
        data = {
          address = "127.0.0.1";
          database = "minecraft";
          username = "minecraft";
          password = "@DATABASE_PASSWORD@";
          table-prefix = "luckperms_";
        };
        messaging-service = "sql";
      };
    };
    symlinks = {
      "plugins/ViaVersion.jar" = pkgs.fetchurl rec {
        pname = "ViaVersion";
        version = "5.12.0";
        url = "https://github.com/ViaVersion/${pname}/releases/download/${version}/${pname}-${version}.jar";
        hash = "sha256-csQKanAtZ/Im/JoNitgquhSD/avi5hWbzd2y3AcHULA=";
      };
      "plugins/ViaBackwards.jar" = pkgs.fetchurl rec {
        pname = "ViaBackwards";
        version = "5.12.0";
        url = "https://github.com/ViaVersion/${pname}/releases/download/${version}/${pname}-${version}.jar";
        hash = "sha256-GU6SUCJGMidNezwX5BHgMakiPBhjxvUTjVPHIfB6t40=";
      };
      "plugins/LuckPerms.jar" = let
        build = "1672";
      in
        pkgs.fetchurl rec {
          pname = "LuckPerms";
          version = "5.5.85";
          url = "https://download.luckperms.net/${build}/bukkit/loader/${pname}-Bukkit-${version}.jar";
          hash = "sha256-3GN84Y9I07daf/0XhLhb4Wpic1kJDf5a3xXattFF3H0=";
        };
      "plugins/VillagerInABukkit.jar" = pkgs.fetchurl rec {
        pname = "VillagerInABukkit";
        url = "https://cdn.modrinth.com/data/IAvnm8Mq/versions/f3KfjRWd/VillagerInABukkit-paper-1.6.2.jar?mr_download_reason=standalone";
        hash = "sha256-zuMbD91N1xjXm6EziBI+vFq4V4Arp39DKl1gVAjCOIM=";
      };
      "plugins/SkinsRestorer.jar" = pkgs.fetchurl rec {
        pname = "SkinsRestorer";
        url = "https://cdn.modrinth.com/data/TsLS8Py5/versions/ziIzW16f/SkinsRestorer.jar?mr_download_reason=standalone";
        hash = "sha256-qFtKNw+Yh0HJo49NBJgmLtrL8yIDFHkKwcEnRhmWNZw=";
      };
      "plugins/bluemap.jar" = pkgs.fetchurl rec { # 8100
        pname = "bluemap";
        url = "https://cdn.modrinth.com/data/swbUV1cr/versions/pILlMIlN/bluemap-5.28-paper.jar?mr_download_reason=standalone";
        hash = "sha256-TPtKmWMTLVvgqdsDGiipjp35Le7TfrsHVtOn3Ychq5g=";
      };
      "plugins/FreedomChat.jar" = pkgs.fetchurl rec {
        pname = "FreedomChat";
        url = "https://cdn.modrinth.com/data/MubyTbnA/versions/EizopLcV/FreedomChat-Paper-1.7.10.jar?mr_download_reason=standalone";
        hash = "sha256-KyNxn89k/6aUdjTN9v3F9NEuMrr+x+AO/H/fqKVqe+I=";
      };
      "plugins/BedrockSkinRestorer.jar" = pkgs.fetchurl rec {
        pname = "BedrockSkinRestorer";
        url = "https://cdn.modrinth.com/data/ST76Q4is/versions/m8MPsoNV/BedrockSkinRestorer%5B1.0.5%5D.jar?mr_download_reason=standalone";
        hash = "sha256-GQSULG3rMF1AnpyfvVhcH1LZC2wvd4P+Cz27nOvjlDY=";
      };
      "plugins/simpletpa.jar" = pkgs.fetchurl rec {
        pname = "simpletpa";
        url = "https://cdn.modrinth.com/data/MpPUdJdc/versions/TA1yAaAB/simpletpa-1.8.jar?mr_download_reason=standalone";
        hash = "sha256-4TZq+UMhrMayvPQW74KxTa4ZCrVmPU4osOQ7Uv6KQ4g=";
      };
      "plugins/ChunkLoader.jar" = pkgs.fetchurl rec {
        pname = "ChunkLoader";
        url = "https://cdn.modrinth.com/data/muS1ZQvT/versions/L033gp84/ChunkLoader-1.0.7.jar?mr_download_reason=standalone";
        hash = "sha256-PFYzYzXSAMJ1XAlSPDNoWq4R6eftBzoNkddkOZvXUw0=";
      };
      "plugins/ReplenishPlusPlus.jar" = pkgs.fetchurl rec {
        pname = "ReplenishPlusPlus";
        url = "https://cdn.modrinth.com/data/9rWJrVZX/versions/xK4Zb31a/ReplenishPlusPlus-7.0.0%2Bbuild.260-b1df41e-mc26.3-papermc.jar?mr_download_reason=standalone";
        hash = "sha256-f3CjssYhR1Ie2jc7cNTocJFEXRARCF+8EHSqPxehl3Q=";
      };
      "plugins/veinminer.jar" = pkgs.fetchurl rec { # /veinminer settings mustSneak true
        pname = "veinminer";
        url = "https://cdn.modrinth.com/data/OhduvhIc/versions/oqCXaEfq/veinminer-paper-2.12.2.jar?mr_download_reason=standalone";
        hash = "sha256-vEwn6ycIE3ezdDJcPKJ4pmXqV4pvLWVJBEcFbsJxs9M=";
      };
      "plugins/AxGraves.jar" = pkgs.fetchurl rec {
        pname = "AxGraves";
        url = "https://cdn.modrinth.com/data/Cz6msz34/versions/UlEYAsey/AxGraves-1.32.1.jar?mr_download_reason=standalone";
        hash = "sha256-BjWFlMLuMDK93b5HO3YFwjtIYxxrQRYfGw9j25kt/Hg=";
      };
      "plugins/headdrop.jar" = pkgs.fetchurl rec {
        pname = "headdrop";
        url = "https://cdn.modrinth.com/data/mT6OgveE/versions/j0dOHL8P/headdrop-3.1.0.jar?mr_download_reason=standalone";
        hash = "sha256-g7zSlLhEBlGq28dgRYLQhb//2smHtPHL2dpC8oSErlM=";
      };
      "plugins/Plan.jar" = pkgs.fetchurl rec { # 8804
        pname = "Plan";
        url = "https://cdn.modrinth.com/data/wJQfHhxh/versions/h1A8YZWx/Plan-5.8-build-3638.jar?mr_download_reason=standalone";
        hash = "sha256-CASwBTIF+AfIXNPE9Z8HpUr7gcb/Vj3SSRXjqVVhLIw=";
      };
      "plugins/UndyingPets.jar" = pkgs.fetchurl rec {
        pname = "UndyingPets";
        url = "https://cdn.modrinth.com/data/AVhwYiSD/versions/p2i5EwJm/Undying%20Pets-1.0.0.0.jar?mr_download_reason=standalone";
        hash = "sha256-9waBUe8hF7r4EsGt2T9KVXugmIL8obz65HkMIiomWIQ=";
      };
      "plugins/MobHealth.jar" = pkgs.fetchurl rec {
        pname = "MobHealth";
        url = "https://cdn.modrinth.com/data/VLCY8WJF/versions/hK5BZUvL/MobHealth-2.0.3.jar?mr_download_reason=standalone";
        hash = "sha256-I5lN1INR3ApqJC50gLhAIXJC4Ea9cF4IcoIj/IIqmfw=";
      };
      "plugins/lock-end.jar" = pkgs.fetchurl rec {
        pname = "lock-end";
        url = "https://cdn.modrinth.com/data/rSEEI32A/versions/qxwC1tAW/lock-end-2.0.1.jar?mr_download_reason=standalone";
        hash = "sha256-A9nVTyw9p2Fj/h58v/N9wUowFuv9UGJdjAaSjL/R9X8=";
      };
      "plugins/SmartInventory.jar" = pkgs.fetchurl rec { # double click on empty space to sort
        pname = "SmartInventory";
        url = "https://cdn.modrinth.com/data/nSYXpKTb/versions/fwNVghOJ/SmartInventory-1.5.jar?mr_download_reason=standalone";
        hash = "sha256-+SHrBF1DCKGfdRlvjmMws9DrRsSnVDehMn40sae0eg4=";
      };
      "plugins/hug.jar" = pkgs.fetchurl rec {
        pname = "hug";
        url = "https://cdn.modrinth.com/data/djBJRfda/versions/QDVeV2AF/hug-n-marry-paper-1.5.jar?mr_download_reason=standalone";
        hash = "sha256-K5ablREanOzjrSWlAZ/7NgHRnmX4qbCVuPAJnKQSDaA=";
      };
      "plugins/ExtendedHorizons.jar" = pkgs.fetchurl rec {
        pname = "ExtendedHorizons";
        url = "https://cdn.modrinth.com/data/RTpACLoD/versions/NVFZZ7Wa/ExtendedHorizons-3.2.2-release.jar?mr_download_reason=standalone";
        hash = "sha256-hNmwrU6IYPtFzPJ6g14M9sYSCawzuDWz5aURm1a2fts=";
      };
      "plugins/RedstoneProtect.jar" = pkgs.fetchurl rec {
        pname = "RedstoneProtect";
        url = "https://cdn.modrinth.com/data/97HrDxDx/versions/kBYm7u8M/RedstoneProtect-1.0.1-P.jar?mr_download_reason=standalone";
        hash = "sha256-FuDRA+NWlxQcUiQtkPL63trlYXG8QQbZf7USiDjL1Hs=";
      };
      "plugins/jreiproxyserver.jar" = pkgs.fetchurl rec { # Allow JEI
        pname = "jreiproxyserver";
        url = "https://cdn.modrinth.com/data/YZH9K7m0/versions/O5JEsMBk/jreiproxyserver-26.3.0.jar?mr_download_reason=standalone";
        hash = "sha256-TOn5+KaPYO8/fEO4Sx05kqReRoTtvt8vOxuF02exL88=";
      };
    };
  };
}