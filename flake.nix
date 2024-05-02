{
  inputs = { nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"; };

  outputs = { self, nixpkgs }: {
    nixosConfigurations.nixos-musl =
      let pkgsGnu = import nixpkgs { system = "x86_64-linux"; };
      in nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [./nixos/configuration.nix];
      };
  };
}
