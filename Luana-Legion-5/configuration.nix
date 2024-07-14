# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, outputs, config, home-manager,pkgs, pkgsGnu, pkgsMusl, pkgsNoCu, pkgsOld, pkgsWivrn, pkgsmndvlknlyrs, lib, stdenv, fetchFromGitHub, ... }:

{
  imports =
    [ ../common/common.nix
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Install firefox.
  # programs.firefox.enable = true; # I use Epiphany now (on my laptop)

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = [
  pkgs.git
  pkgs.krita
  pkgs.weylus
  pkgs.ulauncher
  pkgs.vscodium
  pkgs.font-manager
  pkgs.lshw
  pkgs.xfce.xfce4-whiskermenu-plugin
  pkgs.remmina
  ((pkgs.wrapOBS { # OBS
      plugins = [
      pkgs.obs-studio-plugins.wlrobs
      pkgsNoCu.obs-studio-plugins.obs-backgroundremoval
      pkgs.obs-studio-plugins.obs-pipewire-audio-capture
  ];}))
  pkgs.xfce.xfce4-panel-profiles
  pkgs.xfce.xfce4-pulseaudio-plugin
  pkgs.xfce.xfce4-clipman-plugin
  pkgs.menulibre
  ];

  # Flatpaks (enabled in common.nix)
  services.flatpak.update.onActivation = true;
  services.flatpak.remotes = [
    { name = "flathub"; location = "https://dl.flathub.org/repo/flathub.flatpakrepo"; }
    { name = "epiphany-preview"; location = "https://nightly.gnome.org/gnome-nightly.flatpakrepo"; }
    { name = "webkit"; location = "https://software.igalia.com/flatpak-refs/webkit-sdk.flatpakrepo"; }
  ];
  services.flatpak.packages = [
    { appId = "org.gnome.Epiphany.Devel"; origin = "epiphany-preview"; }
    { appId = "org.gnome.Epiphany.Canary"; origin = "epiphany-preview"; }
   "com.valvesoftware.SteamLink"
  ];

  # Kernel Modules
  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback
  ];
  security.polkit.enable = true;

  # Bootloader.
  boot.loader = {
    efi.canTouchEfiVariables = true;
    grub = { enable = true;
      efiSupport = true;
      device = "nodev";
      useOSProber = true;
      extraEntries = ''
        menuentry "UEFI Firmware Settings" { fwsetup }
      '';
      # theme = "${builtins.fetchGit{url = "https://github.com/qdwp/CyberRe.git";}}/CyberRe";
      # theme = "${builtins.fetchGit{url = "https://github.com/Patato777/dotfiles.git";}}/grub/themes/virtuaverse";
      theme = "${builtins.fetchGit{url = "https://github.com/nobreDaniel/dotfile.git";}}/Arcade";
    };
  };

  networking.hostName = "Luana-Legion-5"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

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

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the XFCE Desktop Environment.
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.xfce.enable = true;

  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "br";
    xkb.variant = "";
  };

  # Configure console keymap
  console.keyMap = "br-abnt2";

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
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.luana = {
    isNormalUser = true;
    description = "Luana";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  # Syncthing (enabled in common.nix)
  services.syncthing = {
    user = "luana";
    dataDir = "/home/luana/Documents";    # Default folder for new synced folders
    configDir = "/home/luana/.config/syncthing";   # Folder for Syncthing's settings and keys
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };


  # NVidia Drivers
  # Enable OpenGL
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = [ pkgsmndvlknlyrs.monado-vulkan-layers ];
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
    open = false; # TODO: this will become the default for newer GPUs (such as mine) soon, check how good this is

    # Enable the Nvidia settings menu,
	# accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # CUDA
  systemd.services.nvidia-control-devices = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig.ExecStart = "${pkgs.linuxPackages.nvidia_x11.bin}/bin/nvidia-smi";
  };
  environment.sessionVariables = rec {
    CUDA_PATH = "${pkgs.cudatoolkit}";
    CUDA_TOOLKIT_ROOT_DIR = "${pkgs.cudatoolkit}";
    EXTRA_LDFLAGS = "-L/lib -L${pkgs.linuxPackages.nvidia_x11}/lib";
    LD_LIBRARY_PATH = lib.mkForce "${pkgs.linuxPackages.nvidia_x11}/lib:${pkgs.ncurses5}/lib:${config.services.pipewire.package.jack}/lib";
    EXTRA_CCFLAGS = "-I/usr/include";
  };
  hardware.nvidia.prime = {
    #sync.enable = true;
    
    # Make sure to use the correct Bus ID values for your system!
    nvidiaBusId = "PCI:1:0:0";
    amdgpuBusId = "PC5I:5:0:0";
  };


  # List services that you want to enable:

  # Enable the OpenSSH daemon.
   services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 7860 1701 9001 4000 5353 9757 ];
  networking.firewall.allowedUDPPorts = [ 7860 1701 9001 4000 5353 9757 ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Run normal binaries
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = [config.boot.kernelPackages.nvidiaPackages.stable] ++ (with pkgs; [
    libva # fuck alvr, they removed the appimages
    ocamlPackages.alsa
    alsa-lib
    xfce.libxfce4windowing
    xfce.xfwm4
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cudatoolkit
    cups
    curl
    dbus
    expat
    fontconfig
    freetype
    fuse3
    gdk-pixbuf
    glib
    gtk3
    icu
    libGL
    libappindicator-gtk3
    libdrm
    libglvnd
    libnotify
    libpulseaudio
    libunwind
    libusb1
    libuuid
    libxkbcommon
    libxml2
    mesa
    nspr
    nss
    openssl
    pango
    pipewire
    systemd
    vulkan-loader
    xorg.libX11
    xorg.libXScrnSaver
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXrandr
    xorg.libXrender
    xorg.libXtst
    xorg.libxcb
    xorg.libxkbfile
    xorg.libxshmfence
    zlib
  ]);


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
