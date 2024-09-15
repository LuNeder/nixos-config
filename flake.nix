{
  nixConfig = {
    extra-substituters = [
      "https://cuda-maintainers.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
    ];
  };
  inputs = { nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"; 
    pkgs-old.url = "github:nixos/nixpkgs/nixos-23.11";
    pkgs-wivrn.url = "github:PassiveLemon/nixpkgs/wivrn-init"; # TODO: remove when merged
    pkgs-mndvlknlyrs.url = "github:Scrumplex/nixpkgs/nixos/monado/vulkan-layers"; # TODO: remove when merged
    pkgs-alvr.url = "github:jopejoe1/nixpkgs/alvr-src"; # TODO: remove when merged
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    systems.url = "github:nix-systems/default-linux";
    compiz-reloaded.url = "github:LuNeder/compiz-reloaded-nix";
    compiz-reloaded.inputs.nixpkgs.follows = "nixpkgs";
    compiz.url = "github:LuNeder/compiz-reloaded-nix/compiz09";
    compiz.inputs.nixpkgs.follows = "nixpkgs";
    nix-flatpak.url = "github:gmodena/nix-flatpak"; 
    nix-software-center.url = "github:snowfallorg/nix-software-center";
    nixos-conf-editor.url = "github:snowfallorg/nixos-conf-editor";
    snow.url = "github:snowfallorg/snow";
  };

  outputs = { self, nixpkgs, pkgs-old, pkgs-wivrn, pkgs-mndvlknlyrs, pkgs-alvr, systems, nix-flatpak, home-manager, ... } @ inputs: 
    let 
      inherit (self) outputs;
      lib = nixpkgs.lib // home-manager.lib;
      pkgsMusl = import nixpkgs { config.allowUnfree = true; hostPlatform.config = "x86_64-unknown-linux-musl";}; # config.cudaSupport = true; config.cudaVersion = "12";}; 
      pkgsGnu = import nixpkgs {  config.allowUnfree = true; hostPlatform.config = "x86_64-unknown-linux-gnu"; config.cudaSupport = true; config.cudaVersion = "12";}; 
      pkgs = import nixpkgs { config.allowUnfree = true; hostPlatform.config = "x86_64-unknown-linux-gnu"; config.cudaSupport = true; config.cudaVersion = "12";}; # TODO: CHANGE FOR MUSL + nix seems to ignore when i ask it to use musl
      pkgsNoCu = import nixpkgs { config.allowUnfree = true; hostPlatform.config = "x86_64-unknown-linux-gnu";};
      pkgsOld = import pkgs-old { config.allowUnfree = true; hostPlatform.config = "x86_64-unknown-linux-gnu";}; 
      pkgsWivrn = import pkgs-wivrn { config.allowUnfree = true; hostPlatform.config = "x86_64-unknown-linux-gnu"; config.cudaSupport = true; config.cudaVersion = "12";}; 
      pkgsmndvlknlyrs = import pkgs-mndvlknlyrs { config.allowUnfree = true; hostPlatform.config = "x86_64-unknown-linux-gnu"; config.cudaSupport = false;}; # TODO: broken due to opencv, add cuda
      pkgsAlvr = import pkgs-alvr { config.allowUnfree = true; hostPlatform.config = "x86_64-unknown-linux-gnu"; config.cudaSupport = true; config.cudaVersion = "12";}; 
    in {
      nixosConfigurations = {
        virtualbox = ( nixpkgs.lib.nixosSystem {
            specialArgs = {inherit inputs outputs pkgs pkgsGnu pkgsMusl pkgsNoCu pkgsOld pkgsWivrn pkgsmndvlknlyrs pkgsAlvr;};
            modules = [./virtualbox/nixos/configuration.nix];
        });
        virtualbox2 = ( nixpkgs.lib.nixosSystem {
            specialArgs = {inherit inputs outputs pkgs pkgsGnu pkgsMusl pkgsNoCu pkgsOld pkgsWivrn pkgsmndvlknlyrs pkgsAlvr;};
            modules = [./virtualbox2/nixos/configuration.nix];
        });
        Luana-X670E = ( nixpkgs.lib.nixosSystem {
            specialArgs = {inherit inputs outputs pkgs pkgsGnu pkgsMusl pkgsNoCu pkgsOld pkgsWivrn pkgsmndvlknlyrs pkgsAlvr;};
            modules = [ nix-flatpak.nixosModules.nix-flatpak
              ./Luana-X670E/configuration.nix];
        });
        Luana-Legion-5 = ( nixpkgs.lib.nixosSystem {
            specialArgs = {inherit inputs outputs pkgs pkgsGnu pkgsMusl pkgsNoCu pkgsOld pkgsWivrn pkgsmndvlknlyrs pkgsAlvr;};
            modules = [ nix-flatpak.nixosModules.nix-flatpak
              ./Luana-Legion-5/configuration.nix];

      });
      };
    };
}
