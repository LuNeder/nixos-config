{ pkgs, inputs, outputs, config, home-manager, lib, stdenv, fetchFromGitHub, rustPlatform, ... }: {
  
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  nixpkgs.config.allowUnfree = true; # Allow unfree packages

  # Common Packages
  environment.systemPackages = [
    pkgs.curl
    pkgs.zfs
    pkgs.htop
    pkgs.sops
    pkgs.killall # ok, at this point im just disappointed that not even this is installed by default
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

  # Trusted users
  nix.settings.trusted-users = [
    "root"
    "@wheel"
  ];

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

  # Sops
  sops.defaultSopsFile = ../secrets/secrets.yaml;
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  # Trust SSL cert for NAS
  security.pki.certificateFiles = [
    ../Yoke/rootCA.pem
    ../Yoke/yoke+11.pem
  ];

  # Git
  programs.git.enable = true;
  programs.git.lfs.enable = true;

  # Tailscale
  services.tailscale.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "prohibit-password";
  };
  programs.ssh.forwardX11 = true;
  programs.ssh.setXAuthLocation = true;
  users.users."root".openssh.authorizedKeys.keys = [
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINjD+1Cg8f9wbB17u6JZxwUUDE1HCIu8QqwCSC3tqWWX luana@Luana-X670E"
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDEn6lCcUrD2A9Pppfgv0CUjCAMrUwgDI+6bDHolL0Lw luana@Luana-Legion-5"
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGW6PtCADYRtvF76Ba7u7+NNoOtjDRjRkb3W1d3/W9ol root@iPhone"
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII5UXentRtMK6btQM0LsMuQWoYkAFMtbUdAMxTQJZekq root@Yoke"
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII5UXentRtMK6btQM0LsMuQWoYkAFMtbUdAMxTQJZekq root@Yoke"
  ''command="poweroff",restrict ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKTjuUP73g64SDoVNQIzarbeOxDeiVMpGmNrpaPr3D4k hass@Yoke''
  ];
  users.users."luana".openssh.authorizedKeys.keys = config.users.users."root".openssh.authorizedKeys.keys;

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
      cdn = "cd ~/nixos-config";
    };
  };

}