{ config, pkgs, lib, ... }:
let
  mkDailyOneWaySync = srcs: destpath: { # TODO: these lets could be global for all machines somehow
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
      chown = "sync:personalfiles";
      chmod = 770;
    };
    inhibit = [ "idle" "sleep" "shutdown" "handle-lid-switch" ];
  };
  srv = "sync@100.64.0.9";
  backups = config.services.restic.backups;
in
{
  services.rsync = {
    enable = true;
    jobs = {
      "Imagens" = mkDailyOneWaySync ["/home/luana/Imagens/"] "/mnt/pool1/PersonalFiles/Media/Laptop/Imagens/";
      "Videos" = mkDailyOneWaySync ["/home/luana/Vídeos/"] "/mnt/pool1/PersonalFiles/Media/Laptop/Videos/";
      "Documentos" = mkDailyOneWaySync ["/home/luana/Documentos/"] "/mnt/pool1/PersonalFiles/Documentos/Laptop/"; # TODO: make two-way sync 
      "Steam-screenshots" = mkDailyOneWaySync ["/home/luana/.local/share/Steam/userdata/329790549/760/remote/"] "/mnt/pool1/PersonalFiles/Media/Laptop/Steam/screenshots";
    };
  };

  services.restic.backups = {
    laptop-luana-home = {
      environmentFile = config.sops.templates."rustic-env".path;
      initialize = true; # Broken with Rustic due to --no-lock, if on rustic run `sudo restic-laptop-luana-home init` once instead
      #package = pkgs.rustic; # not really drop-in, ugh
      inhibitsSleep = true;
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
      };
      user = "root";
      repository = "rest:http://100.64.0.9:20000/laptop-luana-home";
      pruneOpts = [
        "--keep-last 2"
        "--keep-daily 7"
        "--keep-weekly 2"
        "--keep-monthly 6"
      ];
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
        "/home/luana/ssd2"

        # Synced elsewhere
        "/home/luana/Imagens"
        "/home/luana/Vídeos"
        "/home/luana/Downloads"
        "/home/luana/Documentos"
        "/home/luana/.local/share/Steam/userdata/329790549/760/remote"
      ];
    };
  };
  
  # Set variables for Rustic # using restic for now
  #systemd.services = lib.listToAttrs (builtins.map
  #  (name: lib.nameValuePair "restic-backups-${name}" {
  #    environment.RUSTIC_REPOSITORY = backups.${name}.repository;
  #    environment.RUSTIC_CACHE_DIR = "/var/cache/restic-backups-${name}";
  #  }) (lib.attrNames backups)
  #);

  # Secrets
  sops.secrets = {
    restic-password.sopsFile = ../secrets.yaml;
  };
  sops.templates."rustic-env" = {
    owner = "root";
    group = "root";
    content = ''
      RESTIC_PASSWORD=${config.sops.placeholder."restic-password"}
    '';
  };
}