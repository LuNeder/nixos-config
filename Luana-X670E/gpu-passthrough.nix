# Edited from: https://astrid.tech/2022/09/22/0/nixos-gpu-vfio/
let
  # Integraded GPU - 7950X3D
    # I just want my macOS VM to be usable since software rendering sucks in macOS, so I don't need passthrough for my dedicated NVidia
  gpuIDs = [
    "1002:164e" # Graphics
    "1002:1640" # Audio
  ];
in { pkgs, lib, config, ... }: {
  specialisation."iGPU-Passthrough".configuration = {
    system.nixos.tags = [ "iGPU-Passthrough" ];

      boot = {
        initrd.kernelModules = [
          "vfio_pci"
          "vfio"
          "vfio_iommu_type1"
          #"vfio_virqfd"
        ];
  
        kernelParams = [
          # enable IOMMU
          "amd_iommu=on"
        ] ++
          # isolate the GPU
          [("vfio-pci.ids=" + lib.concatStringsSep "," gpuIDs)];
      };

      virtualisation.spiceUSBRedirection.enable = true;
    };
}