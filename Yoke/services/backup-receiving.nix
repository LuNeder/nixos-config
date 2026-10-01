{ config, pkgs, lib, ... }: {
  users.users.sync = {
    group = "personalfiles";
    isNormalUser = true;
    uid = 1972;
    openssh.authorizedKeys.keys = config.users.users."root".openssh.authorizedKeys.keys ++ [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMjhBKm3Dwak/5NLR6Fw3GP0LQAv2Qas92DJ9Kj47oA4 root@Luana-X670E" ];
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
