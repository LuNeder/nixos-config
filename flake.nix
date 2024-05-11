{
  inputs = { nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"; 
    compiz-reloaded.url = "github:LuNeder/compiz-reloaded-nix";
    compiz-reloaded.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, ... } @ inputs: 
    let 
      inherit (self) outputs;
      pkgsMusl = import nixpkgs { config = "86_64-unknown-linux-musl"; };
      pkgsGnu = import nixpkgs { system = "x86_64-linux"; };
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
        #Luana-X670E = (

        #);
        #Luana-Legion-5 = (

        #);
      };
    };
}
