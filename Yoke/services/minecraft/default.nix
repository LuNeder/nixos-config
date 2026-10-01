{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    inputs.nix-minecraft.nixosModules.minecraft-servers
    ./servers/proxy
    ./servers/limbo
    ./servers/ftb-skies-2-aero
    ./servers/vanilla
  ];
  nixpkgs.overlays = [
    inputs.nix-minecraft.overlay
    (final: prev: {formats = prev.formats // import ./gzipJson.nix { pkgs = final; };})
  ];

  sops.secrets.minecraft-secrets = {
    owner = "minecraft";
    group = "minecraft";
    mode = "0440";
    sopsFile = ./secrets.yaml;
    # minecraft-secrets: "DATABASE_PASSWORD='password-here'"
    # velocity-fwd: "secret-here"
  };

  services.minecraft-servers = {
    enable = true;
    eula = true;
    environmentFile = config.sops.secrets.minecraft-secrets.path;
    managementSystem = {
      tmux.enable = false;
      systemd-socket.enable = true;
    };
  };

  services.mysql = {
    enable = true;
    package = lib.mkDefault pkgs.mariadb;
    ensureDatabases = ["minecraft"];
    ensureUsers = [
      {
        name = "minecraft";
        ensurePermissions = {
          "minecraft.*" = "ALL PRIVILEGES";
        };
      }
    ];
  };
  # Set minecrafts' password (the plugins don't play well with socket auth)
  users.users.mysql.extraGroups = ["minecraft"]; # Get access to the secret
  users.users.mysql.isSystemUser = true;
  users.users.mysql.group = "mysql";
  users.users.mysql.uid = 84;
  users.groups.mysql = { gid = 84; };
  users.groups.minecraft = { gid = 973; };
  systemd.services.mysql.postStart = lib.mkAfter ''
    source ${config.sops.secrets.minecraft-secrets.path}
    ${config.services.mysql.package}/bin/mysql <<EOF
      ALTER USER 'minecraft'@'localhost'
        IDENTIFIED VIA unix_socket OR mysql_native_password
        USING PASSWORD('$DATABASE_PASSWORD');
    EOF
  '';
}
