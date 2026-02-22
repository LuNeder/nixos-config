{ config, pkgs, lib, ... }: {
  services.cage = {
    enable = true;
    program = "${lib.getExe pkgs.klipperscreen}";
    user = "root";
    extraArguments = [ "-d" ];
  };

  # wait for network and DNS
  systemd.services."cage-tty1".after = [
    "network-online.target"
    "systemd-resolved.service"
  ];
}