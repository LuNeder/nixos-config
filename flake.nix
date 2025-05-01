{
  nixConfig = {
    extra-substituters = [
      "https://cuda-maintainers.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
    ];
  };
  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; 

    zen-browser.url = "github:youwen5/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";

    nixos-cosmic.url = "github:lilyinstarlight/nixos-cosmic";
    nixos-cosmic.inputs.nixpkgs.follows = "nixpkgs";
    nixos-cosmic.inputs.nixpkgs-stable.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    systems.url = "github:nix-systems/default-linux";

    compiz-reloaded.url = "github:LuNeder/compiz-reloaded-nix";
    compiz-reloaded.inputs.nixpkgs.follows = "nixpkgs";

    compiz.url = "github:LuNeder/compiz-reloaded-nix/compiz09";
    compiz.inputs.nixpkgs.follows = "nixpkgs";

    lanzaboote.url = "github:nix-community/lanzaboote";

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
  };

  

  outputs = { self, nixpkgs, systems, nix-flatpak, home-manager, plasma-manager, ... } @ inputs: 
    let
      inherit (self) outputs;
      lib = nixpkgs.lib // home-manager.lib; 
    in {
      nixosConfigurations = {
        virtualbox = ( nixpkgs.lib.nixosSystem {
            specialArgs = {inherit inputs outputs;};
            modules = [./virtualbox/nixos/configuration.nix];
        });
        virtualbox2 = ( nixpkgs.lib.nixosSystem {
            specialArgs = {inherit inputs outputs;};
            modules = [./virtualbox2/nixos/configuration.nix];
        });
        Luana-X670E = ( nixpkgs.lib.nixosSystem {
            specialArgs = {inherit inputs outputs;};
            modules = [ nix-flatpak.nixosModules.nix-flatpak
              ./Luana-X670E/configuration.nix];
        });
        Luana-Legion-5 = ( nixpkgs.lib.nixosSystem {
            specialArgs = {inherit inputs outputs;};
            modules = [ nix-flatpak.nixosModules.nix-flatpak
              ./Luana-Legion-5/configuration.nix];
        });
        Yoke = ( nixpkgs.lib.nixosSystem {
            specialArgs = {inherit inputs outputs;};
            modules = [ nix-flatpak.nixosModules.nix-flatpak
              ./Yoke/configuration.nix];
        });
      };
    };
}
