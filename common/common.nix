{ pkgs, inputs, outputs, config, home-manager, lib, stdenv, fetchFromGitHub, rustPlatform, ... }: {

  # Packagesets
  nixpkgs.config.allowUnfree = true; # Allow unfree packages
  nixpkgs.overlays = [
    (final: prev: {
      # TODO: check if this unhardcoding of the arch in hostPlatform.config actually works
      pkgsGnu = import inputs.nixpkgs {  config.allowUnfree = true;  localSystem.system = final.stdenv.hostPlatform.system; localSystem.config = "${pkgs.hostPlatform.linuxArch}-unknown-linux-gnu"; config.cudaSupport = true; config.cudaVersion = "12";}; 
      # pkgsMusl = import inputs.nixpkgs { config.allowUnfree = true;  localSystem.system = final.stdenv.hostPlatform.system; localSystem.config = "${pkgs.hostPlatform.linuxArch}-unknown-linux-musl";}; # config.cudaSupport = true; config.cudaVersion = "12";}; 
      pkgsNoCu = import inputs.nixpkgs { config.allowUnfree = true;  localSystem.system = final.stdenv.hostPlatform.system; localSystem.config = "${pkgs.hostPlatform.config}"; }; # TODO: Nix ignores when I change this to musl...
    }
    )
  ];

  # Common Packages
  environment.systemPackages = [
    pkgs.curl
    pkgs.zfs
    pkgs.nvtopPackages.full
    pkgs.htop
    pkgs.p7zip # why is this not installed by default, nixos is fucking dumb
    pkgs.rar
    pkgs.xz
    pkgs.lm_sensors
    pkgs.ifuse
    pkgs.libimobiledevice # Needed to connect iPhone
    pkgs.neofetch
    pkgs.lolcat
    pkgs.killall # ok, at this point im just disappointed that not even this is installed by default
    pkgs.direnv
    pkgs.appimage-run # nixos just cant work out of the box, can it? needed for appimages
    pkgs.x264
    pkgs.yt-dlp
    pkgs.pciutils
  ];

  # Enable sysrq keys that for some dumb reason come disabled by default
  boot.kernel.sysctl."kernel.sysrq" = 1;

  # Garbage Collector
  nix.settings.auto-optimise-store = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "-d --delete-older-than 30d";
  };

  # Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.extraOptions = "experimental-features = nix-command flakes";

  # Add flake inputs to registry
  nix.registry = lib.mapAttrs (_: flake: {inherit flake;}) (lib.filterAttrs (_: lib.isType "flake") inputs);
  nix.nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") (lib.filterAttrs (_: lib.isType "flake") inputs);

  # Keyring for bitwarden
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.lightdm.enableGnomeKeyring = true; # TODO: Not Working, annoying af

  # Flatpaks
  xdg.portal.extraPortals = [pkgs.kdePackages.xdg-desktop-portal-kde];
  xdg.portal.enable = true;
  services.flatpak.enable = true; # for when i move from xfce: https://nixos.wiki/wiki/Flatpak

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  programs.ssh.forwardX11 = true;
  programs.ssh.setXAuthLocation = true;

  # Zsh
  environment.shells = [ pkgs.zsh ];
  users.defaultUserShell = pkgs.zsh;
  programs.zsh = {
     enable = true;
     enableCompletion = true;
     autosuggestions.enable = true;
     syntaxHighlighting.enable = true;

    ohMyZsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "agnoster";
    };

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

  # Git
  programs.git.enable = true;
  programs.git.lfs.enable = true;

  
  # Tailscale
  services.tailscale.enable = true;

  # Syncthing
  services.syncthing.enable = true;

  # Sudo
  security.sudo = {
  enable = true;
  extraRules = [{
    commands = [
      {
        command = "${pkgs.systemd}/bin/reboot";
        options = [ "NOPASSWD" ];
      }
      {
        command = "${pkgs.systemd}/bin/poweroff";
        options = [ "NOPASSWD" ];
      }
      {
        command = "/run/current-system/sw/bin/poweroff";
        options = [ "NOPASSWD" ];
      }
    ];
    groups = [ "wheel" ];
  }];
  extraConfig = with pkgs; ''
    Defaults insults
  '';
};

# Zfs
boot.supportedFilesystems = [ "zfs" ];
services.zfs.autoScrub.enable = true;
services.zfs.trim.enable = true;


}