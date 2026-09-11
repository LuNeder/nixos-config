{
  pkgs,
  lib,
  ...
}: {
  services.minecraft-servers.servers.proxy = rec {
    extraStartPost = ''
      echo 'lpv import initial.json.gz' > /run/minecraft/proxy.stdin
    '';
    extraReload = extraStartPost;

    symlinks = {
      "plugins/LuckPerms.jar" = let
        build = "1669";
      in
        pkgs.fetchurl rec {
          pname = "LuckPerms";
          version = "5.5.82";
          url = "https://download.luckperms.net/${build}/velocity/${pname}-Velocity-${version}.jar";
          hash = "sha256-2hjfqmFsDrJHfEaxQhv9OS/P6OTVoKWWJitRutftydM=";
        };
      "plugins/luckperms/initial.json.gz".format = pkgs.formats.gzipJson {};
      "plugins/luckperms/initial.json.gz".value = let
        mkPermissions = lib.mapAttrsToList (key: value: {inherit key value;});
      in {
        groups = {
          owner.nodes = mkPermissions {
            "group.admin" = true;
            "prefix.1000.&5" = true;
            "weight.1000" = true;

            "librelogin.*" = true;
            "luckperms.*" = true;
            "velocity.command.*" = true;
          };
          admin.nodes = mkPermissions {
            "group.default" = true;
            "prefix.900.&6" = true;
            "weight.900" = true;

            "huskchat.command.broadcast" = true;
          };
          default.nodes = mkPermissions {
            "huskchat.command.channel" = true;
            "huskchat.command.msg" = true;
            "huskchat.command.msg.reply" = true;
          };
        };
        users = {
          "830b6d31-e82a-46bf-85b6-8253d2ef5d3e" = {
            username = "Luana_MNP";
            nodes = mkPermissions {"group.owner" = true;};
          };
        };
      };
    };

    files = {
      "plugins/luckperms/config.yml".value = {
        server = "proxy";
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
  };
}
