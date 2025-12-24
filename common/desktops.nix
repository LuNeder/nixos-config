{ pkgs, inputs, outputs, config, home-manager, lib, stdenv, fetchFromGitHub, rustPlatform, ... }: {
  imports = [ ./common.nix ];

  # Bluetooth GUI
  services.blueman.enable = true;

  # Common Packages
  environment.systemPackages = [
    pkgs.pkgsCu.nvtopPackages.full
    pkgs.xfce.xfce4-terminal
  ];

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

}