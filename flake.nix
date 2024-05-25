{
  inputs = { nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"; 
    systems.url = "github:nix-systems/default-linux";
    # compiz-reloaded.url = "github:LuNeder/compiz-reloaded-nix";
    # compiz-reloaded.inputs.nixpkgs.follows = "nixpkgs";
    compiz.url = "github:LuNeder/compiz-reloaded-nix/compiz09";
    compiz.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, systems, ... } @ inputs: 
    let 
      inherit (self) outputs;
      lib = nixpkgs.lib ;# // home-manager.lib;
      forEachSystem = f: lib.genAttrs (import systems) (system: f pkgsFor.${system});
      pkgsFor = lib.genAttrs (import systems) (
      system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        });
      pkgsMusl = import nixpkgs { system = "x86_64-unknown-linux-musl"; config.allowUnfree = true; }; 
      pkgsGnu = import nixpkgs { system = "x86_64-linux"; config.allowUnfree = true; }; 
     # pkgs = pkgsFor.x86_64-linux; # TODO: PROBABLY CHANGE FOR MUSL
    in {
      nixosConfigurations = {
        virtualbox = ( nixpkgs.lib.nixosSystem {
            specialArgs = {inherit inputs outputs pkgsGnu pkgsMusl;};
            modules = [./virtualbox/nixos/configuration.nix];
        });
        virtualbox2 = ( nixpkgs.lib.nixosSystem {
            specialArgs = {inherit inputs outputs pkgsGnu pkgsMusl;};
            modules = [./virtualbox2/nixos/configuration.nix];
        });
        Luana-X670E = ( nixpkgs.lib.nixosSystem {
            specialArgs = {inherit inputs outputs pkgsGnu pkgsMusl;};
            pkgs = pkgsFor.x86_64-linux;
            modules = [./Luana-X670E/nixos/configuration.nix];
        });
        #Luana-Legion-5 = (

        #);
      };
    };
}
