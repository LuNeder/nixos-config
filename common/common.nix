{ pkgs, inputs, outputs, config, home-manager, lib, stdenv, fetchFromGitHub, rustPlatform, ... }: {

  imports = [ 
    ./minimal.nix
    inputs.nix-flatpak.nixosModules.nix-flatpak
  ];

  # Packagesets
  nixpkgs.overlays = [
    (final: prev: {
      # TODO: check if this unhardcoding of the arch in hostPlatform.config actually works
      pkgsGnu = import inputs.nixpkgs {  config.allowUnfree = config.nixpkgs.config.allowUnfree;  localSystem.system = final.stdenv.hostPlatform.system; localSystem.config = "${final.stdenv.hostPlatform.linuxArch}-unknown-linux-gnu"; config.cudaSupport = true; config.cudaVersion = "12";}; 
      # pkgsMusl = import inputs.nixpkgs { config.allowUnfree = config.nixpkgs.config.allowUnfree;  localSystem.system = final.stdenv.hostPlatform.system; localSystem.config = "${final.stdenv.hostPlatform.linuxArch}-unknown-linux-musl";}; # config.cudaSupport = true; config.cudaVersion = "12";}; 
      pkgsNoCu = import inputs.nixpkgs { config.allowUnfree = config.nixpkgs.config.allowUnfree;  localSystem.system = final.stdenv.hostPlatform.system; localSystem.config = "${final.stdenv.hostPlatform.config}"; }; # TODO: Nix ignores when I change this to musl...
      pkgsCu = import inputs.nixpkgs {  config.allowUnfree = config.nixpkgs.config.allowUnfree;  localSystem.system = final.stdenv.hostPlatform.system; localSystem.config = "${final.stdenv.hostPlatform.config}"; config.cudaSupport = true; config.cudaVersion = "12";}; # For machines without full cudaSupport enabled
      pkgsOld = import inputs.nixpkgs-old {  config.allowUnfree = config.nixpkgs.config.allowUnfree;  localSystem.system = final.stdenv.hostPlatform.system; localSystem.config = "${final.stdenv.hostPlatform.linuxArch}-unknown-linux-musl"; config.cudaSupport = true; config.cudaVersion = "12";};
    })

    #(final: prev: {
    #  libimobiledevice = prev.libimobiledevice.overrideAttrs {
    #   patches = [
    #    (pkgs.fetchpatch {
    #      name = "1619.patch";
    #      url = "https://github.com/libimobiledevice/libimobiledevice/pull/1619.patch";
    #      hash = "sha256-XpeGOF2KRRmXfIXFtt+5Lyg3bSJhaPnLPbTZeklil64=";
    #    })
    #   ];
    #  };
    #  
    #  upower = prev.upower.overrideAttrs {
    #   checkPhase = "echo awawa";
    #  };
    #  power-profiles-daemon = prev.power-profiles-daemon.overrideAttrs {
    #   checkPhase = "echo awawa";
    #  };
    #})
  ];

  # Common Packages
  environment.systemPackages = [
    pkgs.p7zip # why is this not installed by default, nixos is fucking dumb
   # pkgs.rar # TODO: Broken in aarch64
    pkgs.xz
    pkgs.lm_sensors
    pkgs.ifuse
    pkgs.libimobiledevice # Needed to connect iPhone
    pkgs.pkgsOld.neofetch # Removed from nixpkgs bc nixos maintainers suck
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

  # Mullvad
  services.mullvad-vpn = {
    enable = true;
    package = pkgs.mullvad-vpn;
  };

}