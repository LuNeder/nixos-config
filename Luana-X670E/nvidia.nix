({ lib, config, pkgs, ... }: {
  config = #lib.mkIf (config.specialisation != {}) 
  {
    # Config that should only apply to the default system, not the specialised ones

    # NVidia Drivers
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

    boot.kernelParams = [ "nvidia_drm.fbdev=1" ];

    # CUDA
    systemd.services.nvidia-control-devices = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig.ExecStart = "${pkgs.linuxPackages.nvidia_x11.bin}/bin/nvidia-smi";
    };
    environment.sessionVariables = rec {
      CUDA_PATH = "${pkgs.cudatoolkit}";
      CUDA_TOOLKIT_ROOT_DIR = "${pkgs.cudatoolkit}";
      EXTRA_LDFLAGS = "-L/lib -L${pkgs.linuxPackages.nvidia_x11}/lib";
     # LD_LIBRARY_PATH = lib.mkForce "${pkgs.linuxPackages.nvidia_x11}/lib:${pkgs.ncurses5}/lib:${config.services.pipewire.package.jack}/lib";
      EXTRA_CCFLAGS = "-I/usr/include";
    };

    # Enable CUDA system-wide (causes lots of builds)
    nixpkgs.config.cudaSupport = true;

    # Enable MPS to try to reduce context switching and see if it avoids the endemic XID 109 CTX SWITCH TIMEOUT errors in some games
    systemd.services.nvidia-mps = {
      description = "NVIDIA CUDA Multi-Process Service";
      after = [ "nvidia-persistenced.service" ];
      requires = [ "nvidia-persistenced.service" ];
      wantedBy = [ "multi-user.target" ];
      path = [ config.hardware.nvidia.package.bin ];
      serviceConfig = {
        Type = "forking";
        ExecStart = "${config.hardware.nvidia.package.bin}/bin/nvidia-cuda-mps-control -d";
        ExecStop = "${pkgs.writeShellScript "nvidia-mps-stop" ''
          echo quit | ${config.hardware.nvidia.package.bin}/bin/nvidia-cuda-mps-control
        ''}";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
  };
})