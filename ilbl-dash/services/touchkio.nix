{ config, pkgs, lib, stdenv, ... }: 
let
  touchkio = (
      pkgs.stdenv.mkDerivation (finalAttrs: {
        pname = "touchkio";
        version = "1.4.2";

        src = pkgs.fetchurl {
          url = "https://github.com/leukipp/touchkio/releases/download/v${finalAttrs.version}/touchkio-linux-arm64-${finalAttrs.version}.zip";
          hash = "sha256-Jkdv/KcKxdc3uKa9K7yal3l5UGR55e1Pd6Ydrw7n/cU=";
        };

        #unpackPhase = "dpkg -xR $src .";

        nativeBuildInputs = with pkgs; [
          #dpkg
          unzip
          autoPatchelfHook
          qt5.wrapQtAppsHook
          #electron
          nspr
          nss
          at-spi2-core
          cups
          cairo
          gtk3
          pango
          libXdamage
          libXrandr
          mesa
          alsa-lib
        ];

        installPhase = ''
          runHook preInstall
          
          chmod -R 755 ./*
          mkdir -p $out/bin
          mkdir -p $out/share/touchkio
          mv ./* $out/share/touchkio/

          makeWrapper "$out/share/touchkio/touchkio" "$out/bin/touchkio" \
            --chdir "$out/share/touchkio" \
            --prefix PATH : "${lib.makeBinPath finalAttrs.nativeBuildInputs}"

          runHook postInstall
        '';

        meta.mainProgram = "touchkio";
      })
    );
in
{
  services.cage = {
    enable = true;
    program = "${lib.getExe touchkio}";
    user = "root";
    extraArguments = [ "-d" ];
  };

  environment.systemPackages = [
    touchkio
  ];

  # wait for network and DNS
  systemd.services."cage-tty1".after = [
    "network-online.target"
    "systemd-resolved.service"
  ];

#  nixpkgs.overlays = [
#    (final: prev: {
#      libsecret = prev.libsecret.overrideAttrs {
#        doCkeck = false;
#      };
#    })
#  ];
}
