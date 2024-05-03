{
  inputs = { nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"; };

  outputs = { self, nixpkgs, ... } @ inputs: let
    inherit (self) outputs;
 in {
    nixosConfigurations = {
virtualbox ={
        specialArgs = {inherit inputs outputs;};
        modules = [./virtualbox];
      };
  };
};
}
