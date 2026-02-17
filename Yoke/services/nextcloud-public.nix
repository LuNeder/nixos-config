{ config, pkgs, lib, inputs, ... }: {
  # See oraclevps nginx.nix
   #TODO: Not working
  config.var = {
    enablePublicNextcloud = false; # Only for small periods of time when needed
  };

  options.var = with lib.types; {
    enablePublicNextcloud = lib.mkOption { type = bool; };
  };
}