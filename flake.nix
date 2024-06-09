{
  nixConfig = {
    substituters = [
      "https://cuda-maintainers.cachix.org"
    ];
    trusted-public-keys = [
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
    ];
  };
  inputs = { nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"; 
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    systems.url = "github:nix-systems/default-linux";
    compiz-reloaded.url = "github:LuNeder/compiz-reloaded-nix";
    compiz-reloaded.inputs.nixpkgs.follows = "nixpkgs";
    compiz.url = "github:LuNeder/compiz-reloaded-nix/compiz09";
    compiz.inputs.nixpkgs.follows = "nixpkgs";
    nix-flatpak.url = "github:gmodena/nix-flatpak";
  };

  outputs = { self, nixpkgs, systems, nix-flatpak, home-manager, ... } @ inputs: 
    let 
      inherit (self) outputs;
      lib = nixpkgs.lib // home-manager.lib;
      pkgsMusl = import nixpkgs { config.allowUnfree = true; hostPlatform.config = "x86_64-unknown-linux-musl";}; # config.cudaSupport = true; config.cudaVersion = "12";}; 
      pkgsGnu = import nixpkgs {  config.allowUnfree = true; hostPlatform.config = "x86_64-unknown-linux-gnu"; config.cudaSupport = true; config.cudaVersion = "12";}; 
      pkgs = import nixpkgs { config.allowUnfree = true; hostPlatform.config = "x86_64-unknown-linux-gnu"; config.cudaSupport = true; config.cudaVersion = "12";}; # TODO: CHANGE FOR MUSL + nix seems to ignore when i ask it to use musl
    in {
      nixosConfigurations = {
        virtualbox = ( nixpkgs.lib.nixosSystem {
            specialArgs = {inherit inputs outputs pkgs pkgsGnu pkgsMusl;};
            modules = [./virtualbox/nixos/configuration.nix];
        });
        virtualbox2 = ( nixpkgs.lib.nixosSystem {
            specialArgs = {inherit inputs outputs pkgs pkgsGnu pkgsMusl;};
            modules = [./virtualbox2/nixos/configuration.nix];
        });
        Luana-X670E = ( nixpkgs.lib.nixosSystem {
            specialArgs = {inherit inputs outputs pkgs pkgsGnu pkgsMusl;};
            modules = [ nix-flatpak.nixosModules.nix-flatpak
              ./Luana-X670E/configuration.nix];
        });
        #Luana-Legion-5 = (

        #);
      };
    };
}
