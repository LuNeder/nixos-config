{ ... }: {
  services.komga = {
    enable = true;
    openFirewall = true;
    stateDir = "/mnt/pool1/Komga";
    group = "personalfiles"; # ideally would be read-only, but don't want to mess with ACL and I can put the sticky bit anyway
    settings = {
      server = {
        port = 25600; # Komga default that isn't the default in nix for some reason
      };
    };
  };
}
