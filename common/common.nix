{ inputs, outputs, config, home-manager,pkgs, pkgsGnu, pkgsMusl, pkgsNoCu, pkgsOld, pkgsWivrn, pkgsmndvlknlyrs, lib, stdenv, fetchFromGitHub, ... }: {

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

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true; # done at flake.nix bc nix is dumb af and ignores this when using flakes

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