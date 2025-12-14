{ config, pkgs, lib, inputs, ... }: let
  port = 7500;
  host = "[::]";
  dataDir = "/mnt/pool1/yt-dlp";
in {
  environment.systemPackages = [
    (pkgs.writeScriptBin "viddownload" (builtins.readFile ./viddownload.sh))
    (pkgs.writeScriptBin "webui_viddownload.py" (builtins.readFile ./webui_viddownload.py))
    pkgs.brush
    pkgs.yt-dlp
  ]; 

    systemd.services = {
    "viddownload-webui" = {
      path = [ 
        (pkgs.writeScriptBin "viddownload" (builtins.readFile ./viddownload.sh))
        pkgs.brush
        pkgs.yt-dlp
        (pkgs.python3.withPackages (python-pkgs: [
          python-pkgs.flask
          python-pkgs.gunicorn
        ]))
      ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        User = "viddownload";
        Group = "viddownload";
        ProtectHome = true;
        ProtectSystem = "full";
        # StateDirectory = dataDir;
        ReadWritePaths = dataDir;
        PrivateTmp = false;
        StateDirectoryMode = "0775";
        UMask = "007";
        #WorkingDirectory = "/tmp/viddownload";
        DynamicUser = false;
        Restart = "on-failure";
        ExecStart = (pkgs.writeScript "viddownload-webui-starter" ''
          #!/usr/bin/env brush
          gunicorn --workers 3 --pythonpath '${(pkgs.writeScriptBin "webui_viddownload.py" (builtins.readFile ./webui_viddownload.py))}/bin' --bind '${host}:${toString port}' --umask 0o007 webui_viddownload:app
        '');
      };
    };
  };

  users.users.viddownload = {
    group = "viddownload";
    home = dataDir;
    isSystemUser = true;
  };

  networking.firewall.allowedTCPPorts = [ port ];
}