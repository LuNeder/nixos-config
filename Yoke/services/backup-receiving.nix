{ config, pkgs, lib, ... }: {
  users.users.sync = {
    group = "personalfiles";
    isSystemUser = true;
    openssh.authorizedKeys.keys = config.users.users."root".openssh.authorizedKeys.keys;
  };

  services.restic.server = {
    enable = true;
    dataDir = "/mnt/pool1/backups/restic";
    listenAddress = "20000";
    extraFlags = [ "--no-auth" "--listen" "[::]:20000" ];
  };
  systemd.sockets.restic-rest-server.enable = lib.mkForce false;
  systemd.services.restic-rest-server = {
    after = [ "network.target" ];
    requires = lib.mkForce [ ];
    serviceConfig = {
      PrivateNetwork = lib.mkForce false;
      RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" ];
    };
  };

  networking.firewall.allowedTCPPorts = [ 20000 ];
  networking.firewall.allowedUDPPorts = [ 20000 ];
}
