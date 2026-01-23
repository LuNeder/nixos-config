{ pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../common/minimal.nix
  ];

  # Workaround for https://github.com/NixOS/nix/issues/8502
  services.logrotate.checkConfig = false;

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  networking = {
    hostName = "oraclevps";
    domain = "subnet09211736.vcn02091442.oraclevcn.com";
    interfaces = {
      ens3 = {
        useDHCP = false;
        ipv4 = {
          addresses = [
            {
              address = "10.0.0.33";
              prefixLength = 24;
            }
          ];
          routes = [
            {
              address = "10.0.0.33";
              prefixLength = 24;
              via = "10.0.0.1";
            }
            {
              address = "10.0.0.0";
              prefixLength = 24;
            }

          ];
        };
        ipv6 = {
          addresses = [
            {
              address = "2603:c021:c00a:3300::33";
              prefixLength = 128;
            }
          ];
        };
      };
    };
  };
  services.openssh.enable = true;

  users.users.luana = {
    isNormalUser = true;
    description = "Luana";
    extraGroups = [ "networkmanager" "wheel" "personalfiles" "budgetfiles" "viddownload" ];
    packages = with pkgs; [];
  };

  system.stateVersion = "23.11";
  
}
