{ config, pkgs, lib, ... }: {
  systemd.services.ustreamer = {
    wantedBy = [ "network.target" ];
    description = "uStreamer for video2";
    serviceConfig = {
      Type = "simple";
      ExecStart = ''${(pkgs.writeShellApplication {name = "ustreamer-setup"; text = "udevadm control --reload && udevadm trigger --subsystem-match=video4linux && ${pkgs.ustreamer}/bin/ustreamer -d /dev/webcam-ender --encoder=HW --persistent --drop-same-frames=30";})}/bin/ustreamer-setup'';
    };
  };


  services.fluidd.nginx.locations."/webcam".proxyPass = "http://127.0.0.1:8080/stream";

  # Udev Rules
  services.udev.extraRules = ''
    # Match by USB vendor/product and optional serial, make a symlink /dev/webcam-front
    SUBSYSTEM=="video4linux", KERNEL=="video*", ATTRS{idVendor}=="046d", ATTRS{serial}=="738AD79F", SYMLINK+="webcam-ender", MODE="0666"
  '';
}


