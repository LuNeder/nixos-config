{ config, pkgs, ... }:
let
  mkDailyOneWaySync = usr: srcs: destpath: { 
    user = usr; 
    group = usr; 
    sources = srcs; 
    destination = "${srv}:${destpath}"; 
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
    settings = {
      archive = true;
      partial = true;
      mkpath = true;
    };
    inhibit = [ "idle" "sleep" "shutdown" "handle-lid-switch" ]; 
  };
  srv = "sync@192.168.15.9";
in
{
  services.rsync = {
    enable = true;
    jobs = {
      "Imagens" = mkDailyOneWaySync "luana" ["/home/luana/Imagens/"] "/mnt/pool1/PersonalFiles/Media/PC/Imagens/";
      "Videos" = mkDailyOneWaySync "luana" ["/home/luana/Vídeos/"] "/mnt/pool1/PersonalFiles/Media/PC/Videos/";
      "Steam-screenshots" = mkDailyOneWaySync "luana" ["/home/luana/.local/share/Steam/userdata/329790549/760/remote/"] "/mnt/pool1/PersonalFiles/Media/PC/Steam/screenshots";
    };
  };

  services.restic.backups = {
    pc-luana-home = {
      environmentFile = config.sops.templates."rustic-env".path;
      initialize = true;
      package = pkgs.rustic;
      inhibitsSleep = true;
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
      };
      user = "root";
      repository = "rest:http://192.168.15.9:20000/pc-luana-home";
      paths = [
        "/home/luana"
      ];
      exclude = [
        "/home/luana/.cache"
        "/home/luana/.local/share/Trash"
        "/home/luana/.local/share/Steam/common"
        "/home/luana/.local/share/Steam/steamapps/workshop"
        "/home/luana/.local/share/Steam/steamapps/temp"
        "/home/luana/.local/share/Steam/compatibilitytools.d"
        "/home/luana/.local/state/Heroic/logs"
        "/home/luana/Games/Heroic"

        # Synced elsewhere
        "/home/luana/Imagens"
        "/home/luana/Vídeos"
        "/home/luana/Downloads"
        # "/home/luana/Documentos" # TODO: Add when two-way sync is added
        "/home/luana/.local/share/Steam/userdata/329790549/760/remote"
      ];
    };
  };

  sops.secrets = {
    restic-password.sopsFile = ../secrets.yaml;
  };

  sops.templates."rustic-env" = {
    owner = "restic";
    group = "restic";
    content = ''
      RUSTIC_PASSWORD = ${config.sops.placeholder.restic-password}
    '';
  };
}