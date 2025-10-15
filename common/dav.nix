{ config, pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.cifs-utils
    pkgs.davfs2
  ];

  sops.secrets = {
    #smbcreds = {
    #  mode = "0600";
    #};
    davfs = {
      mode = "0600";
      path = "/etc/davfs2/secrets";
      sopsFile = ../secrets.yaml;
    };
  };

  services.davfs2.enable = true;

  systemd.mounts = [
    #{
    #  description = "Samba mount for homeserver media";
    #  after = [ "network-online.target" ];
    #  wants = [ "network-online.target" ];
    #  what = "//192.168.200.101/media";
    #  where = "/mnt/homeserver-media";
    #  options = "credentials=${config.sops.secrets.smbcreds.path},iocharset=utf8,rw,x-systemd.automount,uid=1000,gid=100,vers=3";
    #  type = "cifs";
    #}
    {
      description = "Nextcloud webdav mount";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      what = "http://192.168.15.9/remote.php/dav/files/luana";
      where = "/home/luana/Nextcloud";
      options = "x-systemd.automount,uid=${toString config.users.users.luana.uid},gid=100";
      type = "davfs";
    }
  ];
  systemd.automounts = [
    {
      description = "Nextcloud webdav automount";
      where = "/home/luana/Nextcloud";
      wantedBy = [ "multi-user.target" ];
      automountConfig = {
        TimeoutIdleSec = "2m";
      };
    }
  ];
}