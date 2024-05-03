{
  inputs = { nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"; };

  outputs = { self, nixpkgs, ... } @ inputs: let inherit (self) outputs;
  in {
    nixosConfigurations = {
      virtualbox = (
        let 
         pkgsMusl = import nixpkgs { system = "86_64-unknown-linux-musl"; };
         pkgsGnu = import nixpkgs { system = "x86_64-linux"; };
        in nixpkgs.lib.nixosSystem {
          specialArgs = {inherit inputs outputs pkgsMusl;};
          modules = [./nixos/configuration.nix];
        });
    };
  };
}
