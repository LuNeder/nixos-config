# Base configuration for system-manager non-NixOS devices such as the phones
{ pkgs, inputs, outputs, config, home-manager, lib, stdenv, fetchFromGitHub, rustPlatform, ... }: {
  
  imports = [
      inputs.sops-nix.nixosModules.sops
    ] ++ (builtins.attrValues inputs.merpkgs.systemManagerModules) ++
    (builtins.attrValues inputs.merpkgs.homeModules)

  ;

  nixpkgs.config.allowUnfree = true; # Allow unfree packages

  # Common Packages
  environment.systemPackages = [
    pkgs.curl
    pkgs.htop
    pkgs.sops
    pkgs.tailscale
    pkgs.git
    pkgs.mosh
    pkgs.zsh
    pkgs.oh-my-zsh
    pkgs.powerline-fonts
  ];

  environment.variables = {
    # Show nix apps on menus
    XDG_DATA_DIRS = ''$XDG_DATA_DIRS:$HOME/.nix-profile/share:/run/current-system/sw/share:${builtins.concatStringsSep ":" (map (pkg: "${pkg}/share") config.environment.systemPackages)}'';
  };

  environment.etc.environment = {
    text = ''
      #
      # This file is parsed by pam_env module
      #
      # Syntax: simple "KEY=VAL" pairs on separate lines
      #
      
      # dbus cannot see the XDG variable set elsewhere, so we need to set this here to avoid a "name is not activatable error" on Desktop icons
      # Manually set var from scratch, bc adding $VARIABLES breaks the graphical session
      XDG_DATA_DIRS=/var/lib/flatpak/exports/share:/usr/local/share:/usr/share:/nix/var/nix/profiles/default/share:/run/current-system/sw/share
    '';
    mode = "0655";
    user = "root";
    group = "root";
  };

  environment.pathsToLink = [ "/share" ]; # Also for menu icons, with this the mapping above is probably not needed
  
  # No garbage collector on system-manager?
  nix.settings.auto-optimise-store = true;

  # Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.extraOptions = "experimental-features = nix-command flakes";

  # Trusted users
  nix.settings.trusted-users = [
    "root"
    "luana"
    "@wheel"
  ];

  # Sudo
  security.sudo = {
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
      Defaults pwfeedback
    '';
  };

  # Sops
  sops.defaultSopsFile = ../secrets/secrets.yaml;
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  # Enable the OpenSSH daemon.
  services.openssh = {
    settings = { 
      PermitRootLogin = "prohibit-password";
      X11Forwarding = true;
      Macs = [
        # Default
        "hmac-sha2-512-etm@openssh.com"
        "hmac-sha2-256-etm@openssh.com"
        "umac-128-etm@openssh.com"
        # Non OpenSSH compatib
        "hmac-sha2-256"
      ];
    };
  };
  programs.ssh.forwardX11 = true;
  programs.ssh.setXAuthLocation = true;
  users.users."root".openssh.authorizedKeys.keys = [
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINjD+1Cg8f9wbB17u6JZxwUUDE1HCIu8QqwCSC3tqWWX luana@Luana-X670E"
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDEn6lCcUrD2A9Pppfgv0CUjCAMrUwgDI+6bDHolL0Lw luana@Luana-Legion-5"
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGW6PtCADYRtvF76Ba7u7+NNoOtjDRjRkb3W1d3/W9ol root@iPhone"
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHqBvvXa2BgsnSSFKaDOEnbSkKcVc9nAmaixIUUspM+Z u0_a147@localhost" # termux
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII5UXentRtMK6btQM0LsMuQWoYkAFMtbUdAMxTQJZekq root@Yoke"
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII5UXentRtMK6btQM0LsMuQWoYkAFMtbUdAMxTQJZekq root@Yoke"
  ''command="poweroff",restrict ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKTjuUP73g64SDoVNQIzarbeOxDeiVMpGmNrpaPr3D4k hass@Yoke''
  ];
  users.users."luana".openssh.authorizedKeys.keys = config.users.users."root".openssh.authorizedKeys.keys;
  users.users.luana.isNormalUser = true;

  # Packagesets
  nixpkgs.overlays = [
    inputs.merpkgs.overlays.default
    #(final: prev: { # Infinite recursion on system-manager???
    #  # TODO: check if this unhardcoding of the arch in hostPlatform.config actually works
    #  pkgsGnu = import inputs.nixpkgs {  config.allowUnfree = config.nixpkgs.config.allowUnfree;  localSystem.system = final.stdenv.hostPlatform.system; localSystem.config = "${final.stdenv.hostPlatform.linuxArch}-unknown-linux-gnu"; config.cudaSupport = true; config.cudaVersion = "12";}; 
    #  # pkgsMusl = import inputs.nixpkgs { config.allowUnfree = config.nixpkgs.config.allowUnfree;  localSystem.system = final.stdenv.hostPlatform.system; localSystem.config = "${final.stdenv.hostPlatform.linuxArch}-unknown-linux-musl";}; # config.cudaSupport = true; config.cudaVersion = "12";}; 
    #  pkgsNoCu = import inputs.nixpkgs { config.allowUnfree = config.nixpkgs.config.allowUnfree;  localSystem.system = final.stdenv.hostPlatform.system; localSystem.config = "${final.stdenv.hostPlatform.config}"; }; # TODO: Nix ignores when I change this to musl...
    #  pkgsCu = import inputs.nixpkgs {  config.allowUnfree = config.nixpkgs.config.allowUnfree;  localSystem.system = final.stdenv.hostPlatform.system; localSystem.config = "${final.stdenv.hostPlatform.config}"; config.cudaSupport = true; config.cudaVersion = "12";}; # For machines without full cudaSupport enabled
    #  pkgsOld = import inputs.nixpkgs-old {  config.allowUnfree = config.nixpkgs.config.allowUnfree;  localSystem.system = final.stdenv.hostPlatform.system; localSystem.config = "${final.stdenv.hostPlatform.linuxArch}-unknown-linux-musl"; config.cudaSupport = true; config.cudaVersion = "12";};
    #})
  ];

}