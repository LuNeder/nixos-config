{
  inputs = { nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"; };

  outputs = { self, nixpkgs, lib, ... } {
    nixosConfigurations = {
virtualbox = lib.nixosSystem { modules = [./virtualbox]; };
  };
}
