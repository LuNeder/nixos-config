# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, outputs, config, pkgs, pkgsGnu, pkgsMusl, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      inputs.home-manager.nixosModules.home-manager # Home Manager
      ./hardware-configuration.nix
    ];

# Broken due to uutils issue #6351 # TODO: Wait for fix  # No GNU on this house! Use Uutils instead of GNU coreutils
#  system.replaceRuntimeDependencies = [{
#     original = pkgs.coreutils;
#      replacement = pkgs.uutils-coreutils-noprefix.overrideAttrs (old: {
#       name = pkgs.coreutils.name;
#     });
#   }{
#     original = pkgs.pkgsMusl.coreutils;
#     replacement = pkgs.pkgsMusl.uutils-coreutils-noprefix.overrideAttrs (old: {
#       name = pkgs.pkgsMusl.coreutils.name;
#     });
#   }{
#     original = pkgsGnu.coreutils;
#     replacement = pkgsGnu.uutils-coreutils-noprefix.overrideAttrs (old: {
#       name = pkgsGnu.coreutils.name;
#     });
#   }];



  # TODO: FIX - URGENT ###### Use Musl
   nixpkgs = {
                hostPlatform = { system = "x86_64-linux"; };
  #              # hostPlatform = { config = "x86_64-unknown-linux-musl"; };
  #              config = { replaceStdenv = { pkgs }: pkgs.ccacheStdenv; };
  #              overlays = [
  #                (final: prev: {
  #                  ccacheWrapper = prev.ccacheWrapper.override {
  #                    extraConfig = ''
  #                      export CCACHE_COMPRESS=1
  #                      export CCACHE_DIR="/var/cache/ccache"
  #                      export CCACHE_UMASK=007
  #                      if [ ! -d "$CCACHE_DIR" ]; then
  #                        echo "====="
  #                        echo "Directory '$CCACHE_DIR' does not exist"
  #                        echo "Please create it with:"
  #                        echo "  sudo mkdir -m0770 '$CCACHE_DIR'"
  #                        echo "  sudo chown root:nixbld '$CCACHE_DIR'"
  #                        echo "====="
  #                     #   exit 1
  #                      fi
  #                      if [ ! -w "$CCACHE_DIR" ]; then
  #                        echo "====="
  #                        echo "Directory '$CCACHE_DIR' is not accessible for user $(whoami)"
  #                        echo "Please verify its access permissions"
  #                        echo "====="
  #                    #    exit 1
  #                      fi
  #                    '';
  #                  };
  #                  bind = prev.bind.overrideAttrs (old: { doCheck = false; });
  #                })
  #              ];
              };
  # speed up
  # services.qemuGuest.enable = lib.mkForce false;
  # virtualisation.vmVariant = { virtualisation.host.pkgs = pkgsGnu; };
  ## fixes
  # i18n.glibcLocales = pkgs.stdenv.mkDerivation {
  #    name = "empty";
  #    dontUnpack = true;
  #    installPhase = "mkdir $out";
  # };
  # services.nscd.enableNsncd = false;

  # Latest kernel
  boot.kernelPackages = pkgsGnu.linuxPackages_latest; 

  # Enable sysrq keys that for some dumb reason come disabled by default
  boot.kernel.sysctl."kernel.sysrq" = 1;

  # Bootloader.
  boot.loader = {
    efi = { canTouchEfiVariables = true; };
    grub = { enable = true;
      efiSupport = true;
      device = "nodev";
      useOSProber = true;
      extraEntries = ''
        menuentry "UEFI Firmware Settings" {
          fwsetup
        }
      '';};
  };
  

  networking.hostName = "Luana-X670E"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  services.blueman.enable = true;
  hardware.bluetooth.settings = {
	  General = {
	  	Experimental = true;
  	};
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];



  # Allow unfree packages
  # nixpkgs.config.allowUnfree = true; # done at flake.nix bc nix is dumb af and ignores this when using flakes

  # Keyring for bitwarden
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.lightdm.enableGnomeKeyring = true; # TODO: Not Working, annoying af

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = [
    pkgs.curl
    pkgs.git
    # pkgs.authy
    pkgs.bitwarden-desktop
    pkgs.libsecret
   # inputs.compiz-reloaded.packages.${pkgs.system}.default # Compiz
    inputs.compiz.packages.${pkgs.system}.default
    pkgs.python3Packages.pygobject3
    pkgs.thunderbird
    pkgs.uutils-coreutils-noprefix # not good enough, here just while I don't fix the full replace
    pkgs.nvtopPackages.full
    pkgs.gparted
    pkgs.mate.engrampa
    pkgs.vscodium
    pkgs.goverlay
    pkgs.mangohud
    pkgs.p7zip # why is this not installed by default, nixos is fucking dumb
    pkgs.xz
    pkgs.ulauncher # TODO: autostart ulauncher --hide-window
    pkgs.polybarFull
    pkgs.plank # TODO: autostart
    pkgs.ifuse
    pkgs.syncthing  # TODO: this and tailscale
    pkgs.fastfetch
    pkgs.font-manager
    pkgs.killall # ok, at this point im just disappointed that not even this is installed by default # needed for polybar
  ];

  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    gamescopeSession.enable = true; # TODO: make gamepadui on displaymanager later
  };
  
  # Flatpaks
  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];
  xdg.portal.enable = true;
  services.flatpak.enable = true; # for when i move from xfce: https://nixos.wiki/wiki/Flatpak
  services.flatpak.packages = [
    # "com.obsproject.Studio"
    # "com.bitwarden.desktop"
  ];

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the XFCE Desktop Environment.
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.xfce.enable = true;
  programs.xfconf.enable = true;

  # Desktop Configuration
  home-manager.users.luana = {
    home.stateVersion = "23.11";

    # Autostart Compiz
    xfconf.settings = {
      xfce4-session."sessions/Failsafe/Client1_Command" = [ "xfsettingsd" ];
      xfce4-session."sessions/Failsafe/Client0_Command" = [ "compiz" ];
    };

    
    xdg.configFile = {

      "polybar/config.ini" = { 
        force = true;
        source = /home/luana/Documentos/GitHub/Dotfiles/Polybar/config.ini;  };
      "../.restpolymain" = { 
        force = true;
         source = /home/luana/Documentos/GitHub/Dotfiles/Polybar/.restpolymain;  };

      # Autostart Steam with -silent
      "autostart/steam.desktop" = { 
        force = true;
        source = ./extra-files/steam.desktop;  };
      
      # Autostart ulauncher
      "autostart/ulauncher.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=Ulauncher
        Exec=ulauncher --hide-window
        Comment=
        RunHook=0'';

      # Autostart planck
      "autostart/planck.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=Planck
        Exec=planck
        Comment=
        RunHook=0'';

      # Autostart polybar
      "autostart/polybar.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=Polybar
        Exec=polybar main
        Comment=
        RunHook=0'';
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.luana = {
    isNormalUser = true;
    description = "Luana";
    initialPassword = "abcde"; # so I can login if I do build-vm
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

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
  services.xserver = {
    layout = "us";
    xkbVariant = "intl"; # or intl?
  };

  # Configure console keymap
  console.keyMap = "us-acentos";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;


  #### NVIDIA DRIVERS ####
  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {

    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = false;

    # Enable the Nvidia settings menu,
	# accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };


  ####    ####
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
