{pkgs, ...}: {
  services.minecraft-servers.servers.proxy = {
    extraReload = ''
      echo 'velocitab reload' > /run/minecraft/proxy.stdin
    '';
    symlinks = {
      "plugins/Velocitab.jar" = pkgs.fetchurl rec {
        pname = "Velocitab";
        version = "1.7.9";
        url = "https://github.com/WiIIiam278/${pname}/releases/download/${version}/${pname}-${version}.jar";
        hash = "sha256-pt0ZWeyVFO8D9qXVpL8qWkPG77O1sYQz1K8i8JXm0qU=";
      };
    };
    files = {
      "plugins/velocitab/config.yml".value = {
        fallback_enabled = true;
        fallback_group = "default";
        only_list_players_in_same_group = false;
        remove_spectator_effect = true;
        sort_players = false;
        server_display_names = {};
      };
      "plugins/velocitab/tab_groups.yml".value = {
        groups = [
          {
            name = "default";
            headers = [];
            footers = [];
            format = "&7[%server%] &r%prefix%%username%";
            servers = [];
            header_footer_update_rate = 1000;
            placeholder_update_rate = 1000;
          }
        ];
      };
    };
  };
}
