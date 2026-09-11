# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../common/common.nix
      inputs.lanzaboote.nixosModules.lanzaboote
      ./services/nginx.nix
      ./services/nextcloud.nix
      # ./services/onlyoffice.nix Broken, makes Nextcloud unreachable
      ./services/postgresql.nix
      ./services/home-assistant.nix
      ./services/porn-vault.nix
      ./services/cooklang.nix
      # ./services/pihole.nix
      ./services/adguardhome.nix
      ./services/unbound.nix
      ./services/actual.nix
      ./services/binary-cache/binary-cache.nix
      ./services/yt-dlp/yt-dlp-webui.nix
      ./services/catask/catask.nix
      ./services/immich.nix
      ./services/radicale.nix
      ./services/webdav.nix
      #./services/libreoffice-web.nix # Broken
      ./services/cryptpad.nix
      ./services/wyoming.nix
      ./services/mqtt.nix
      ./services/readeck/readeck.nix
      ./services/komga.nix
      ./services/minecraft
    ];

  # Bootloader.
  boot = {
    initrd.systemd.enable = true;
    loader.systemd-boot.enable = lib.mkForce false;

    # https://jnsgr.uk/2024/04/nixos-secure-boot-tpm-fde/
    # https://github.com/LuNeder/nixos-config/commit/d4b05b1059ad49ea4c3919ef0b0daab39280800c
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };
  };


  networking.hostName = "Yoke"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  networking.networkmanager.ethernet.macAddress = "permanent";
  networking.networkmanager.wifi.macAddress = "permanent";
  networking.interfaces.eno1.wakeOnLan.enable = true;
  # networking.interfaces.thunderbolt0.ipv4.addresses = [{ address = "169.254.24.9"; prefixLength = 24; }];
  # networking.interfaces.thunderbolt0.ipv6.addresses = [{ address = "fe80::9"; prefixLength = 64; }];

  services.hardware.bolt.enable = true;

  # Set your time zone.
  time.timeZone = "America/Sao_Paulo";

  # Select internationalisation properties.
  i18n.defaultLocale = "pt_BR.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NAME = "pt_BR.UTF-8";
    LC_NUMERIC = "pt_BR.UTF-8";
    LC_PAPER = "pt_BR.UTF-8";
    LC_TELEPHONE = "pt_BR.UTF-8";
    LC_TIME = "pt_BR.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "intl";
  };

  # Configure console keymap
  console.keyMap = "us-acentos";

  # Zfs
  boot.supportedFilesystems = [ "zfs" ];
  services.zfs.autoScrub.enable = true;
  services.zfs.trim.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.luana = {
    isNormalUser = true;
    description = "Luana";
    extraGroups = [ "networkmanager" "wheel" "personalfiles" "budgetfiles" "viddownload" ];
    packages = with pkgs; [];
  };

  users.groups.personalfiles = {};
  users.groups.budgetfiles = {};
  users.groups.viddownload = {};

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = [
  #  pkgs.vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  pkgs.curl
    (pkgs.icloudpd.overrideAttrs {
       patches = [
        (pkgs.fetchpatch {
          name = "1290.patch";
          url = "https://github.com/icloud-photos-downloader/icloud_photos_downloader/pull/1290.patch";
          hash = "sha256-E4dNxLMkskwf5EqncEKJRBnJPW6Uq38Wj2qvKDPiGW0=";
        })
       ];
    })
    pkgs.comic-mandown
  ];
 
  programs.git.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

  # Run arm64 binaries
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
