{
  inputs = { nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"; };

  outputs = { self, nixpkgs }: {
    nixosConfigurations.nixos-musl =
      let pkgsGnu = import nixpkgs { system = "x86_64-linux"; };
      in nixpkgs.lib.nixosSystem {
        modules = [
          ({ pkgs, lib, ... }: {
            nixpkgs = {
              hostPlatform = { config = "x86_64-unknown-linux-musl"; };
              config = { replaceStdenv = { pkgs }: pkgs.ccacheStdenv; };
              overlays = [
                (final: prev: {
                  ccacheWrapper = prev.ccacheWrapper.override {
                    extraConfig = ''
                      export CCACHE_COMPRESS=1
                      export CCACHE_DIR="/var/cache/ccache"
                      export CCACHE_UMASK=007
                      if [ ! -d "$CCACHE_DIR" ]; then
                        echo "====="
                        echo "Directory '$CCACHE_DIR' does not exist"
                        echo "Please create it with:"
                        echo "  sudo mkdir -m0770 '$CCACHE_DIR'"
                        echo "  sudo chown root:nixbld '$CCACHE_DIR'"
                        echo "====="
                        exit 1
                      fi
                      if [ ! -w "$CCACHE_DIR" ]; then
                        echo "====="
                        echo "Directory '$CCACHE_DIR' is not accessible for user $(whoami)"
                        echo "Please verify its access permissions"
                        echo "====="
                        exit 1
                      fi
                    '';
                  };
                  bind = prev.bind.overrideAttrs (old: { doCheck = false; });
                })
              ];
            };

            networking.hostName = "nixos-musl";
            boot.loader.systemd-boot.enable = true;
            fileSystems."/" = {
              device = "tmpfs";
              fsType = "tmpfs";
              options = [ "defaults" "size=1G" "mode=755" ];
            };
            system.stateVersion = "23.11";

            # test user
            users.users.root.password = "12345678";
            users.mutableUsers = false;

            # speed up
            boot.kernelPackages = pkgsGnu.linuxPackages;
            services.qemuGuest.enable = lib.mkForce false;
            virtualisation.vmVariant = { virtualisation.host.pkgs = pkgsGnu; };

            # fixes
            i18n.glibcLocales = pkgs.stdenv.mkDerivation {
              name = "empty";
              dontUnpack = true;
              installPhase = "mkdir $out";
            };
            services.nscd.enableNsncd = false;
          })
        ];
      };
  };
}
