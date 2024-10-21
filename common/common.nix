{ pkgs, inputs, outputs, config, home-manager, lib, stdenv, fetchFromGitHub, ... }: {

  # Packagesets
  nixpkgs.config.allowUnfree = true; # Allow unfree packages
  nixpkgs.config.cudaSupport = true; # Enable CUDA
  nixpkgs.overlays = [
    (final: prev: {
      # TODO: unhardcode hostPlatform.config (how to unhardcode the x86_64 part without removing -musl?)
      # pkgsMusl = import inputs.nixpkgs { config.allowUnfree = true;  localSystem.system = final.stdenv.hostPlatform.system; localSystem.config = "x86_64-unknown-linux-musl";}; # config.cudaSupport = true; config.cudaVersion = "12";}; 
      pkgsGnu = import inputs.nixpkgs {  config.allowUnfree = true;  localSystem.system = final.stdenv.hostPlatform.system; localSystem.config = "x86_64-unknown-linux-gnu"; config.cudaSupport = true; config.cudaVersion = "12";}; 
      pkgsNoCu = import inputs.nixpkgs { config.allowUnfree = true;  localSystem.system = final.stdenv.hostPlatform.system; localSystem.config = "x86_64-unknown-linux-gnu"; }; # TODO: Nix ignores when I change this to musl...
      # pkgsOld = import inputs.pkgs-old { config.allowUnfree = true;  localSystem.system = final.stdenv.hostPlatform.system; localSystem.config = "x86_64-unknown-linux-musl"; }; 
      pkgsWivrn = import inputs.pkgs-wivrn { config.allowUnfree = true;  localSystem.system = final.stdenv.hostPlatform.system; localSystem.config = "x86_64-unknown-linux-gnu"; config.cudaSupport = true; config.cudaVersion = "12";}; # TODO: Merged, remove 
      pkgsmndvlknlyrs = import inputs.pkgs-mndvlknlyrs { config.allowUnfree = true;  localSystem.system = final.stdenv.hostPlatform.system; localSystem.config = "x86_64-unknown-linux-gnu"; config.cudaSupport = true; config.cudaVersion = "12";};
      pkgsAlvr = import inputs.pkgs-alvr { config.allowUnfree = true;  localSystem.system = final.stdenv.hostPlatform.system; localSystem.config = "x86_64-unknown-linux-gnu"; config.cudaSupport = true; config.cudaVersion = "12";};
      }
    )
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
  nix.registry = builtins.mapAttrs (_name: value: {flake = value;}) inputs;

  # Keyring for bitwarden
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.lightdm.enableGnomeKeyring = true; # TODO: Not Working, annoying af

  # TeamViewer
  services.teamviewer.enable = true;

  # RDP
  services.xrdp.enable = true;
  services.xrdp.openFirewall = true;


  # KDE Connect
  programs.kdeconnect.enable = true;

  # Extra Fonts
  fonts.packages = [
    pkgs.powerline-fonts # zsh agnoster theme needs this
    # pkgs.emojione # NixOS/nixpkgs#326959
    pkgs.minecraftia
    pkgs.comic-relief
    pkgs.comic-mono
    pkgs.fira
  ];

  # Flatpaks
  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];
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


}