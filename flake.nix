{
  nixConfig = {
    extra-substituters = [
      "https://bincache.yoke.sereia.gay"
      "https://nixos-raspberrypi.cachix.org"
    ];
    extra-trusted-public-keys = [
      "yoke-bin-cache:ddWddUNLU59tCn5o6xwweO88tXpcnJql6pqpF2aYkc4="
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
  };
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    merpkgs = {
      url = "github:LuNeder/merpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    system-manager = {
      url = "github:numtide/system-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-old.url = "github:NixOS/nixpkgs/nixos-25.11";

    zen-browser.url = "github:youwen5/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    systems.url = "github:nix-systems/default-linux";

    compiz-reloaded.url = "github:LuNeder/compiz-reloaded-nix";
    compiz-reloaded.inputs.nixpkgs.follows = "nixpkgs";

    compiz.url = "github:LuNeder/compiz-reloaded-nix/compiz09";
    compiz.inputs.nixpkgs.follows = "nixpkgs";

    lanzaboote.url = "github:nix-community/lanzaboote";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak"; 
    
    nix-software-center.url = "github:snowfallorg/nix-software-center";
    nix-software-center.inputs.nixpkgs.follows = "nixpkgs";

    nixos-conf-editor.url = "github:snowfallorg/nixos-conf-editor";
    nixos-conf-editor.inputs.nixpkgs.follows = "nixpkgs";

    snow.url = "github:snowfallorg/snow";
    snow.inputs.nixpkgs.follows = "nixpkgs";

    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/main";
    #nixos-raspberrypi.inputs.nixpkgs.follows = "nixpkgs";

    librepods = {
      url = "github:kavishdevar/librepods/linux/rust";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-minecraft = {
      url = "github:Infinidoge/nix-minecraft";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pv-update.url = "github:LuNeder/nixpkgs/porn-vault-update-20260610";
  };

  

  outputs = { self, nixpkgs, systems, nix-flatpak, nixos-raspberrypi, home-manager, system-manager, plasma-manager, ... } @ inputs: 
    let
      inherit (self) outputs;
      lib = nixpkgs.lib // home-manager.lib; 
    in {
      nixosConfigurations = {
        Luana-X670E = ( nixpkgs.lib.nixosSystem {
            specialArgs = {inherit inputs outputs;};
            modules = [ ./Luana-X670E/configuration.nix ];
        });
        Luana-Legion-5 = ( nixpkgs.lib.nixosSystem {
            specialArgs = {inherit inputs outputs;};
            modules = [ ./Luana-Legion-5/configuration.nix ];
        });
        Yoke = ( nixpkgs.lib.nixosSystem {
            specialArgs = {inherit inputs outputs;};
            modules = [ ./Yoke/configuration.nix ];
        });
        Fabricator = ( nixos-raspberrypi.lib.nixosSystemFull {
            specialArgs = {inherit inputs nixos-raspberrypi outputs;};
            modules = [ ./Fabricator/configuration.nix ];
        });
        oraclevps = ( nixpkgs.lib.nixosSystem {
            specialArgs = {inherit inputs outputs;};
            modules = [ ./oraclevps/configuration.nix ];
        });
        ilbl-dash = ( nixos-raspberrypi.lib.nixosSystemFull {
            specialArgs = {inherit inputs nixos-raspberrypi outputs;};
            modules = [ ./ilbl-dash/configuration.nix ];
        });
      };
      systemConfigs = {
        Luana-Fairphone6 = system-manager.lib.makeSystemConfig {
          # Specify your system configuration modules here, for example,
          # the path to your system.nix.
          modules = [ 
              ./Luana-Fairphone6/system.nix 
          ];
          specialArgs = {inherit inputs outputs;};
        };
        luana-note9s = system-manager.lib.makeSystemConfig {
          # Specify your system configuration modules here, for example,
          # the path to your system.nix.
          modules = [ 
              ./luana-note9s/system.nix 
          ];
          specialArgs = {inherit inputs outputs;};

          # Optionally specify extraSpecialArgs and overlays
        };
      };
    };
}
