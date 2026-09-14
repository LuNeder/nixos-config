{pkgs, config, ...}: {
  services.minecraft-servers.servers.proxy = {
    extraReload = ''
      echo 'fairychat reload' > /run/minecraft/proxy.stdin
    '';
    symlinks = {
      "plugins/FairyChat.jar" = pkgs.fetchurl rec {
        pname = "FairyChat";
        version = "0.7.7";
        url = "https://github.com/rexlManu/${pname}/releases/download/v${version}/${pname}-${version}.jar";
        hash = "sha256-Pgf4cGF6AaO8oSl9GQiYxpv6labxy/U2/4nydGaE7Vg=";
      };
      "plugins/SignedVelocity.jar" = pkgs.fetchurl rec {
        pname = "SignedVelocity";
        version = "1.5.0";
        url = "https://github.com/4drian3d/${pname}/releases/download/${version}/${pname}-Proxy-${version}.jar";
        hash = "sha256-vQmnRDirYu2SZnDa4ff173Xd1iB41pV0fklLPJfI+UA=";
      };
      "plugins/VPacketEvents.jar" = pkgs.fetchurl rec {
        pname = "VPacketEvents";
        version = "1.2.0";
        url = "https://github.com/4drian3d/${pname}/releases/download/${version}/${pname}-${version}.jar";
        hash = "sha256-AaUPoyk6P9zIYbHJVq72U91Gxg0Nz/njqFbFv1CWGfY=";
      };
    };
    files = {
      "plugins/fairychat/config.yml".value = {
        checkForUpdates = false;

        chatFormat = "<gray>[<server_name>] <display_name></gray>: <message>";

        groupFormats = {};

        displayChatInConsole = true;

        privateMessaging = {
          format = "<dark_gray>[<#00fb9a>PM</#00fb9a>]</dark_gray> <gray><sender_name></gray> → <#00fb9a><recipient_name></#00fb9a>: <message>";
          recipientExpirationSeconds = 300;
          aliases = {
            reply = ["r" "reply"];
            pm = ["msg" "m" "tell" "whisper" "w" "pm"];
          };
        };

        broadcast = {
          format = "<dark_red>[SERVER]</dark_red> <yellow><message></yellow>";
          aliases = ["broadcast" "alert"];
        };

        redis = {
          enabled = true;
          url = "redis://127.0.0.1:${toString config.services.redis.servers.fairychat.port}";
        };

        messages = {
          youCantMessageYourself = "<red>You cannot message yourself.";
          youDidntMessageAnyone = "<red>You haven't messaged anyone yet.";
          youCantMessageThisPlayer = "<red>You cannot message this player.";
          playerNotFound = "<red>Player not found.";
          invalidSyntax = "<red>Invalid syntax. Usage: %usage%";
          noPermission = "<red>You don't have permission to use this command.";
        };
      };
    };
  };

  services.redis.servers.fairychat = {
    enable = true;
    bind = "127.0.0.1";
    port = 6379;
  };
}
