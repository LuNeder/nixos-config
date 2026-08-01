# Base configuration for most NixOS machines, except those with limited specs
{ pkgs, inputs, outputs, config, home-manager, lib, stdenv, fetchFromGitHub, rustPlatform, ... }: {

  imports = [ 
    ./minimal.nix
    inputs.nix-flatpak.nixosModules.nix-flatpak
  ];

  # Common Packages
  environment.systemPackages = [
    pkgs.p7zip # why is this not installed by default, nixos is fucking dumb
   # pkgs.rar # TODO: Broken in aarch64
    pkgs.xz
    pkgs.lm_sensors
    pkgs.ifuse
    pkgs.libimobiledevice # Needed to connect iPhone
    # pkgs.pkgsOld.neofetch # Removed from nixpkgs bc nixos maintainers suck # broken on pkgsOld
    pkgs.lolcat
    pkgs.direnv
    pkgs.appimage-run # nixos just cant work out of the box, can it? needed for appimages
    pkgs.x264
    pkgs.yt-dlp
    pkgs.pciutils
    pkgs.smartmontools
    pkgs.usbutils
    pkgs.tree
    pkgs.libfaketime
    pkgs.brush
    pkgs.fdupes
  ];

  # Tmux
  programs.tmux.enable = true;

  # General Purpose Mouse
  services.gpm = {
    #enable = true;
    protocol = "usb";
  };

  # Bluetooth
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  hardware.bluetooth.settings = {
	  General = {
	  	Experimental = true;
  	};
  };

  # Add flake inputs to registry # TODO: Broken with pipkgs
  #nix.registry = lib.mapAttrs (_: flake: {inherit flake;}) (lib.filterAttrs (_: lib.isType "flake") inputs);
  #nix.nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") (lib.filterAttrs (_: lib.isType "flake") inputs);

  # Keyring for bitwarden
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.lightdm.enableGnomeKeyring = true; # TODO: Not Working, annoying af

  # Flatpaks
  xdg.portal.extraPortals = [pkgs.kdePackages.xdg-desktop-portal-kde];
  xdg.portal.enable = true;
  xdg.portal.config.common.default = "*";
  services.flatpak.enable = true; # for when i move from xfce: https://nixos.wiki/wiki/Flatpak

  # Aliases
  programs.zsh = {
    shellAliases = {
      cargo = "cargo mommy";
      stardustxr-server = "~/Documentos/GitHub/StardustXR/server/target/debug/stardust-xr-server";
      stardustxr-startup = "~/.stardustxr-startup";
      gravity = "~/Documentos/GitHub/StardustXR/gravity/target/debug/gravity";
      flatland = "~/Documentos/GitHub/StardustXR/flatland/target/debug/flatland";
      hexagon-launcher = "~/Documentos/GitHub/StardustXR/protostar/target/debug/hexagon_launcher";
      comet = "~/Documentos/GitHub/StardustXR/comet/target/debug/comet";
      adb-tools = "NIXPKGS_ALLOW_UNFREE=1 nix shell --impure nixpkgs#android-tools nixpkgs#androidenv.androidPkgs.all.packages.platforms.v37_0 nixpkgs#inetutils";
    };
  };

  environment.sessionVariables.CARGO_MOMMYS_ROLES = "big sis";

  # Syncthing
  services.syncthing.enable = true;

  # fwupd
  services.fwupd.enable = true;

  # Needed by ulauncher and heroic-launcher
  nixpkgs.config.permittedInsecurePackages = [
    "libsoup-2.74.3"
  ];

}