{ config, pkgs, lib, inputs, ... }: {
  # Server configuration
  services.nix-serve = {
    enable = true;
    port = 2025;
    openFirewall = true;
    bindAddress = "0.0.0.0"; # https://github.com/miyagawa/Starman/issues/149
    secretKeyFile = config.sops.secrets.cache-sig-key.path;
  };

  sops.secrets.cache-sig-key = {
    sopsFile = ../../secrets.yaml;
  };

  # Updater configuration
  systemd.services = {
    "binary-cache-updater" = {
      path = [ pkgs.brush pkgs.git pkgs.nix config.system.build.nixos-rebuild ];
      restartIfChanged = false;
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        RemainAfterExit = false;
        ExecStart = pkgs.writeScript "binary-cache-updater" (builtins.readFile ./nix-cache.sh);
      };
    };
  };

  systemd.timers."binary-cache-updater" = {
    wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*-*-* 02:30:00 America/Sao_Paulo";
        Unit = "binary-cache-updater.service";
      };
  };

  # Do gc before building to avoid fill storage with too many old builds and avoid removing what we just built (tho the symlink to gcroots should stop the removal on its own)
  nix.gc.dates = lib.mkForce "*-*-* 02:00:00 America/Sao_Paulo";

  services.nginx.virtualHosts."bincache.${config.var.fqdn}" = {
    forceSSL = true;
    sslCertificate = "${config.var.sslCertificate}";
    sslCertificateKey = "${config.var.sslCertificateKey}";
    locations."/".proxyPass = "http://[::1]:${toString config.services.nix-serve.port}";
  };
}
