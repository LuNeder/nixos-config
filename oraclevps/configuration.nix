{ pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./networking.nix
    ../common/minimal.nix
  ];

  # Workaround for https://github.com/NixOS/nix/issues/8502
  services.logrotate.checkConfig = false;

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  networking.hostName = "oraclevps";
  networking.domain = "subnet09211736.vcn02091442.oraclevcn.com";
  services.openssh.enable = true;


  users.users.luana = {
    isNormalUser = true;
    description = "Luana";
    extraGroups = [ "networkmanager" "wheel" "personalfiles" "budgetfiles" "viddownload" ];
    packages = with pkgs; [];
  };

  system.stateVersion = "23.11";
  
}
