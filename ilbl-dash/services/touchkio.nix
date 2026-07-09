{ config, pkgs, lib, stdenv, ... }: {
  services.cage = {
    enable = true;
    program = "touchkio";
    user = "root";
    extraArguments = [ "-d" ];
  };

  environment.systemPackages = [
    (
      stdenv.mkDerivation (finalAttrs: {
        pname = "touchkio";
        version = "1.4.2";

        src = pkgs.fetchurl {
          url = "https://github.com/leukipp/touchkio/releases/download/v${finalAttrs.version}/touchkio_${finalAttrs.version}_arm64.deb";
          hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
        };

        unpackCmd = "dpkg -x $curSrc source";

        nativeBuildInputs = with pkgs; [
          dpkg
          autoPatchelfHook
          qt5.wrapQtAppsHook
          electron
        ];

        installPhase = ''
          runHook preInstall

          mkdir -p $out/bin
          mv ./* $out/

          runHook postInstall
        '';
      })
    )
  ];

  # wait for network and DNS
  systemd.services."cage-tty1".after = [
    "network-online.target"
    "systemd-resolved.service"
  ];
}