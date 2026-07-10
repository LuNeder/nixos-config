{ lib, pkgs, inputs, config, ... }:
{
  imports = [
    ../common/system-manager.nix
    inputs.home-manager.nixosModules.home-manager # Home Manager
  ];
  config = {
    nixpkgs.hostPlatform = "aarch64-linux";
    nixpkgs.config.allowUnfree = true;
    system-manager.allowAnyDistro = true;

    # Enable and configure services
    services = {
      # nginx.enable = true;
    };

    merpkgs.services = {
      ensureAlpinePackages = {
        enable = true;
        packages = [
          "tailscale"
          "firefox"
          "mobile-config-firefox"
          "waydroid"
          "zsh"
          "oh-my-zsh"
          "android-translation-layer"
        ];
      };
    };

    environment = {
      # Packages that should be installed on a system
      systemPackages = [
        # pkgs.android-translation-layer # x86_64 only in nixpkgs for some dumb fucking reason???
        pkgs.nano
        #pkgs.stevia # keyboard (phosh only ;-;)
        pkgs.tuba
        pkgs.telegram-desktop
      ];

      # Add directories and files to `/etc` and set their permissions
      etc = {
        # with_ownership = {
        #   text = ''
        #     This is just a test!
        #   '';
        #   mode = "0755";
        #   uid = 5;
        #   gid = 6;
        # };
        #
        # with_ownership2 = {
        #   text = ''
        #     This is just a test!
        #   '';
        #   mode = "0755";
        #   user = "nobody";
        #   group = "users";
        # };
      };

      #sessionVariables = {
      #  # Show nix apps on menus # Moved to common/system-manager.nix
      #  XDG_DATA_DIRS = ''$XDG_DATA_DIRS:$HOME/.nix-profile/share:${builtins.concatStringsSep ":" (map (pkg: "${pkg}/share") config.environment.systemPackages)}'';
      #};
    };

    # Home Manager
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.sharedModules = [ inputs.plasma-manager.homeModules.plasma-manager ];
    #home-manager.users.luana.programs.plasma = import ./kde.nix; # TODO: maybe someday lol
    home-manager.backupFileExtension = "hm.bkp";
    home-manager.users.luana = {
      home.stateVersion = "26.11";
      home.file = {
      };
    };
    
    # Enable and configure systemd services
    systemd.services = { };

    # Configure systemd tmpfile settings
    systemd.tmpfiles = {
      # rules = [
      #   "D /var/tmp/system-manager 0755 root root -"
      # ];
      #
      # settings.sample = {
      #   "/var/tmp/sample".d = {
      #     mode = "0755";
      #   };
      # };
    };
  };
}
