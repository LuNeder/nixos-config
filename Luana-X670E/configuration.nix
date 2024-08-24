# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, outputs, config, home-manager,pkgs, pkgsGnu, pkgsMusl, pkgsNoCu, pkgsOld, pkgsWivrn, pkgsmndvlknlyrs, pkgsAlvr, lib, stdenv, fetchFromGitHub, ... }:

{
  imports =
    [ 
      ../common/common.nix
      "${inputs.pkgs-wivrn}/nixos/modules/services/video/wivrn.nix"
      inputs.home-manager.nixosModules.home-manager # Home Manager
      ./hardware-configuration.nix
      ./gpu-passthrough.nix
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
#   }]; # TODO: PkgsNoCu



  # TODO: FIX - URGENT ###### Use Musl
   nixpkgs = {
                hostPlatform = { #system = "x86_64-linux";
                  config = "x86_64-unknown-linux-musl"; };
  #             config = { replaceStdenv = { pkgs }: pkgs.ccacheStdenv; };
  #             overlays = [
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


  # Kernel Modules
  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback
  ];
  security.polkit.enable = true;

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
      '';
      theme = "${builtins.fetchGit{url = "https://github.com/qdwp/CyberRe.git";}}/CyberRe";
      # theme = "${builtins.fetchGit{url = "https://github.com/Patato777/dotfiles.git";}}/grub/themes/virtuaverse";
    };
  };
  

  # Plymouth
  boot.initrd.systemd.enable = true;
  boot.plymouth = {
    enable = true;
    themePackages = with pkgs; [ (adi1090x-plymouth-themes.override {selected_themes = [ "black_hud" ]; }) ];
    theme = "black_hud";
  };
  


  networking.hostName = "Luana-X670E"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant. (seems to be working even without this lol)
  networking.interfaces.enp77s0.wakeOnLan.enable = true;
  networking.networkmanager.ethernet.macAddress = "permanent"; # use real Mac address
  networking.networkmanager.wifi.macAddress = "permanent";


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

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = [
    pkgs.curl
    pkgs.git
    pkgs.jdk22
    # pkgsOld.authy
    pkgs.bitwarden-desktop
    pkgs.libsecret
    # inputs.compiz-reloaded.packages.${pkgs.system}.default # Compiz
    inputs.compiz.packages.${pkgs.system}.default
    pkgs.python3Packages.pygobject3
    pkgs.thunderbird
    pkgs.uutils-coreutils-noprefix # not good enough, here just while I don't fix the full replace
    pkgs.nvtopPackages.full
    pkgs.htop
    pkgs.gparted
    pkgs.mate.engrampa
    pkgs.baobab
    pkgs.vscodium
    pkgs.goverlay
    pkgs.mangohud
    pkgs.p7zip # why is this not installed by default, nixos is fucking dumb
    pkgs.rar
    pkgs.xz
    pkgs.ulauncher 
    pkgs.polybarFull # TODO: Fix xfce4-session-logout
    pkgs.plank 
    pkgs.ifuse
    pkgs.fastfetch
    pkgs.neofetch
    pkgs.lolcat
    pkgs.font-manager
    pkgs.killall # ok, at this point im just disappointed that not even this is installed by default # needed for polybar,
    pkgs.direnv
    pkgs.xfce.xfce4-panel-profiles # ...
    pkgs.xfce.xfce4-pulseaudio-plugin
    pkgs.xfce.xfce4-clipman-plugin
    pkgs.menulibre
    pkgs.bibata-cursors # My favourite cursors! (at least for now hehe :3)
    # pkgs.bibata-extra-cursors # broken
    pkgs.graphite-cursors
    pkgs.phinger-cursors
    pkgs.papirus-icon-theme
    (pkgs.wrapOBS { # OBS
      plugins = [
      pkgs.obs-studio-plugins.wlrobs
      pkgsNoCu.obs-studio-plugins.obs-backgroundremoval
      pkgs.obs-studio-plugins.obs-pipewire-audio-capture
    ];})
    pkgs.sg3_utils
    pkgs.protontricks
    pkgs.bottles
    pkgs.prusa-slicer
    pkgs.weylus
    pkgs.krita
    pkgs.inkscape
    pkgs.xournalpp
    pkgs.rnote
    pkgs.github-desktop
    pkgs.discord
    #pkgs.python3.withPackages([pkgs.python3Packages.pyusb pkgs.python311Packages.usb-devices])
    pkgs.python3
    pkgs.python3Packages.pyusb
    pkgs.python311Packages.usb-devices
    pkgs.sidequest
    pkgs.appimage-run # nixos just cant work out of the box, can it? needed for appimages
    pkgs.cudatoolkit # CUDA
    pkgs.cudaPackages.cudnn
    pkgsNoCu.opencomposite
    pkgsNoCu.opencomposite-helper
    pkgs.openxr-loader
    pkgs.xfce.catfish
    pkgs.transmission_4-qt
    pkgs.lldb
    pkgs.alsa-utils
    pkgs.fluidsynth
    pkgs.lmms
    pkgs.muse
    pkgs.qsynth
    pkgs.pavucontrol
    # pkgs.epiphany
    pkgs.netsurf.browser
    # pkgs.minecraft broken
    pkgs.prismlauncher
    pkgs.libreoffice-fresh
    # pkgs.wlx-overlay-s # TODO: reenable - broken
    pkgsAlvr.alvr
    # When using SteamVR, this file cannot exist
    (pkgs.writeShellApplication {name = "wivrn-startup"; text = "cp ~/.config/openvr/wivrn-openvrpaths.vrpath ~/.config/openvr/openvrpaths.vrpath && wivrn-server";})
    pkgs.x264
    pkgs.qpwgraph
    pkgs.pulseaudioFull # Needed for ALVR audio
    pkgs.godot_4
    pkgs.qemu_kvm
    pkgs.cdrkit
    pkgs.quickemu
    pkgs.quickgui
    pkgs.yt-dlp
    pkgs.handbrake
    pkgs.niri
    pkgs.xwayland
    pkgs.jitsi-meet-electron
  ];

  programs.criu.enable = true;


  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    gamescopeSession.enable = true; # TODO: does not work, freezes. make gamepadui on displaymanager manually later
  };

  # VR
  services.monado = {
    package = (pkgsNoCu.monado#.overrideAttrs (oldAttrs: rec { 
     # src = pkgs.fetchFromGitHub {
      #owner = "shinyquagsire23"; # Monado for Oculus Quest
     # repo = "monado";
     # rev = "41abf1e75d443e40c01e3a844d2cdb198d84ded7";
     # hash = "sha256-d5MrRuzQAuA8l7VSQN9A4go6v85fkUT6wmCQEXLnia4=";
     # };})
    );
    enable = true;
    defaultRuntime = false; # Register as default OpenXR runtime
  };
  systemd.user.services.monado.environment = {
    STEAMVR_LH_ENABLE = "1";
    XRT_COMPOSITOR_COMPUTE = "1";
    WMR_HANDTRACKING = "0";
  };
  services.wivrn.enable = true;
  services.wivrn.openFirewall = true;
  services.wivrn.package = pkgsWivrn.wivrn;
  services.wivrn.defaultRuntime = true;
  services.wivrn.config = {
    enable = true;
    json = {
      scale = 1.0;
     # bitrate = 100000000;
      encoders = [
        {
          encoder = "nvenc";
          codec = "h265";
     #     width = 1.0;
       #   height = 1.0;
        #  offset_x = 0.0;
         # offset_y = 0.0;
        }
      ];
      # application = [ pkgs.wlx-overlay-s ]; # TODO: reenable - broken
      #tcp_only = false;
    };
  };
  
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
    brotli
    cairo
    cudatoolkit
    cups
    curl
    dbus
    expat
    fontconfig
    freetype
    fuse3
    ffmpeg
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
    libvdpau
    mesa
    nspr
    nss
    openssl
    pango
    pipewire
    pulseaudio
    systemd
    vulkan-loader
    wayland
    x264
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
  
  # Flatpaks (enabled in common.nix)
  services.flatpak.update.onActivation = true;
  services.flatpak.remotes = [
    { name = "flathub"; location = "https://dl.flathub.org/repo/flathub.flatpakrepo"; }
    { name = "epiphany-preview"; location = "https://nightly.gnome.org/gnome-nightly.flatpakrepo"; }
    { name = "webkit"; location = "https://software.igalia.com/flatpak-refs/webkit-sdk.flatpakrepo"; }
  ];
  services.flatpak.packages = [
    # "com.obsproject.Studio"
    # "com.bitwarden.desktop"
    "org.gnome.Epiphany"
    { appId = "org.gnome.Epiphany.Devel"; origin = "epiphany-preview"; }
    { appId = "org.gnome.Epiphany.Canary"; origin = "epiphany-preview"; }
  ];

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the XFCE Desktop Environment.
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.xfce.enable = true;
  programs.xfconf.enable = true;
  
  # Desktop Configuration
  services.bamf.enable = true; # needed for Plank bc nix dumb nixpkgs#42873
  home-manager.backupFileExtension = "hm.bkp";
  home-manager.users.luana = {
    home.stateVersion = "23.11";

    # Autostart Compiz
    xfconf.settings = {
      xfce4-session."sessions/Failsafe/Client1_Command" = [ "xfsettingsd" ];
      xfce4-session."sessions/Failsafe/Client0_Command" = [ "compiz" ];
    };

    home.file = {
      # StardustXR (needs to be compiled at ~/Documentos/GitHub/StartustXR/*, see zsh aliases on common.nix)
      ".hexagon-launcher" = { 
        executable = true;
        text = ''#!/usr/bin/env zsh
        source /etc/zshrc
        flatland &
        gravity -- 0 0.0 -0.5 hexagon-launcher &
        '';  };
      ".stardustxr-startup" = { 
        executable = true;
        text = ''#!/usr/bin/env zsh
        source /etc/zshrc
        stardustxr-server -o 1 -e "$HOME/.hexagon-launcher" "$@"
        '';  };

    };

    xdg.configFile = {

      # Polybar
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

      # Autostart plank
      "autostart/plank.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=Plank
        Exec=plank
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

      # OpenVR - opencomposite # Use the wivrn-startup script when using wivrn
        # Steam launch args: env PRESSURE_VESSEL_FILESYSTEMS_RW=$XDG_RUNTIME_DIR/wivrn_comp_ipc %command%
      "openvr/wivrn-openvrpaths.vrpath".text = ''
          {
           "config" :
          [
          "~/.local/share/Steam/config"
          ],
          "external_drivers" : null,
          "jsonid" : "vrpathreg",
          "log" :
          [
            "~/.local/share/Steam/logs"
          ],
          "runtime" :
          [
            "${pkgsNoCu.opencomposite}/lib/opencomposite"
          ],
          "version" : 1
        }
      '';
    };

    services.fluidsynth = {
      enable = true;
      soundService = "pipewire-pulse";
    };
  };


  environment.sessionVariables.CURR_SPECIALISATION = "base"; # TODO: problem - this only updates on reboot
  systemd.services.remove-openvr-bkp-file = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig.ExecStart = pkgs.writeShellScript "rmovrbkp" "rm -v -f /home/luana/.config/openvr/openvrpaths.vrpath.hm.bkp";
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
    xkb.layout = "us";
    xkb.variant = "intl";
  };

  # Configure console keymap
  console.keyMap = "us-acentos";

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.avahi = {
  enable = true;
  nssmdns4 = true;
  openFirewall = true;
};

  # Enable sound with pipewire.
  # sound.enable = true; The option definition `sound' no longer has any effect; please remove it.

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

  # OpenRGB
  # services.hardware.openrgb.enable = true;


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:


  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 7860 1701 9001 4000 5353 9757 9943 9944];
  networking.firewall.allowedUDPPorts = [ 7860 1701 9001 4000 5353 9757 9943 9944];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;


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
    # The open kernel module is recommended by NVidia for compatible GPUs, so true is the recommended setting.
    open = true;

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

  
  # Udev Rules
  services.udev.extraRules = ''
    # Apple SuperDrive initialization rule
    # See: https://gist.github.com/yookoala/818c1ff057e3d965980b7fd3bf8f77a6
    ACTION=="add", ATTRS{idProduct}=="1500", ATTRS{idVendor}=="05ac", DRIVERS=="usb", RUN+="${pkgs.sg3_utils}/bin/sg_raw %r/sr%n EA 00 00 00 00 00 01"
  '';

  # Tailscale
  services.tailscale.enable = true;

  # Syncthing (enabled in common.nix)
  services.syncthing = {
    user = "luana";
    dataDir = "/home/luana/Documents";    # Default folder for new synced folders
    configDir = "/home/luana/.config/syncthing";   # Folder for Syncthing's settings and keys
  };

  # services.transmission.enable = true;

  # VirtualBox
  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "luana" ];
  virtualisation.virtualbox.host.enableExtensionPack = true;
  # virtualisation.virtualbox.host.enableKvm = true; ##
  virtualisation.virtualbox.host.enableHardening = false;
  # virtualisation.virtualbox.host.addNetworkInterface = false;

  programs.virt-manager.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
