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
      
      persistence = {
        backup = {
          enable = true;
          maxAmount = 10;
        };
        libraryPath = "/mnt/pool1/porn-vault/lib";
      };
    };
  };

  # Needed for mounting rw on Nextcloud
  systemd.services = {
    "chmod-porn-vault" = {
       wants = [ "porn-vault.service" ];
       serviceConfig = {
         ExecStart = "chmod 777 /mnt/pool1/porn-vault && chmod -R 777 /mnt/pool1/porn-vault/media";
       };
    };
  };
}
