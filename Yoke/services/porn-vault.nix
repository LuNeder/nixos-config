{ config, pkgs, lib, inputs, ... }: {

  services.porn-vault = {
    enable = true;
    openFirewall = true;
    settings = {
      import = {
        images = [
          {
            path = "/mnt/pool1/porn-vault/media";
            include = [ ];
            exclude = [ ];
            extensions = [
              ".jpg"
              ".jpeg"
              ".png"
              ".gif"
            ];
            enable = true;
          }
        ];
        videos = [
          {
            path = "/mnt/pool1/porn-vault/media";
            include = [ ];
            exclude = [ ];
            extensions = [
              ".mp4"
              ".mov"
              ".webm"
            ];
            enable = true;
          }
        ];
        scanInterval = 10800000;
      };

      matching.matcher = {
        options = {
          wordSeparators = [
            "[-_]"
            "%20"
          ];
        };
      };
      
      persistence = {
        backup = {
          enable = true;
          maxAmount = 10;
        };
        libraryPath = "/mnt/pool1/porn-vault/lib";
      };
    };
  };

  services.nginx.virtualHosts."pornvault.${config.var.fqdn}" = {
    forceSSL = true;
    sslCertificate = "${config.var.sslCertificate}";
    sslCertificateKey = "${config.var.sslCertificateKey}";
    extraConfig = ''
      client_max_body_size 30M;
    '';
    locations."/" = {
      proxyPass = "http://[::1]:${toString config.services.porn-vault.port}";
      proxyWebsockets = false;
    };
  };

  # Needed for mounting rw on Nextcloud
  systemd.services = {
    "chmod-porn-vault" = {
       wantedBy = [ "porn-vault.service" ];
       serviceConfig = {
         ExecStart = "${pkgs.writeScript "chmod-porn-vault" "${pkgs.uutils-coreutils-noprefix}/bin/chown root:root /mnt/pool1/porn-vault && ${pkgs.uutils-coreutils-noprefix}/bin/chown -R root:root /mnt/pool1/porn-vault/media && ${pkgs.uutils-coreutils-noprefix}/bin/chmod 777 /mnt/pool1/porn-vault && ${pkgs.uutils-coreutils-noprefix}/bin/chmod 777 /mnt/pool1/porn-vault/media -R"}";
       };
    };
  };
}
