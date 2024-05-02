{
  inputs = { nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"; };

  outputs = { self, nixpkgs, ... } @ inputs: let
    inherit (self) outputs;
 in {
    nixosConfigurations.virtualbox =
      let pkgsGnu = import nixpkgs { system = "x86_64-linux"; };
      in nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs pkgsGnu;};
        modules = [./nixos/configuration.nix];
      };
  };
}
let
    inherit (self) outputs;