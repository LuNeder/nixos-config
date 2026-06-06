{ config, pkgs, lib, inputs, ... }: let
  port = 9980;
in { # TODO: Not working at all
  services.collabora-online = {
    enable = true;
    port = port;
    aliasGroups = [
      {
        host = "http://100.64.0.9:${toString port}";
        aliases = [
          "http://192.168.15.9:${toString port}"
          "https://docs.da.sereia.gay"
        ];
      }
    ];
    settings = {
      server_name = "100.64.0.9:${toString port}";
      ssl = {
        enable = false;
        termination = false;
      };
      net = {
        listen = "any"; # Default is "any"
        # post_allow.host = [ "::1" proxyNetbirdIp serverNetbirdIp ]; # remove server
      };
      storage.wopi = {
        "@allow" = true;
        host = [ config.services.nextcloud.hostName "collabora.${config.var.fqdn}" "docs.da.sereia.gay" "127.0.0.1" "::1" "100.64.0.9" "100.64.0.33" ] ++ config.services.nextcloud.settings.trusted_domains;
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ port 40080 ];
  networking.firewall.allowedUDPPorts = [ port 40080 ];

  services.nginx.virtualHosts."collabora.${config.var.fqdn}" = {
    listen = [{
      addr = "0.0.0.0";
      port = 40080;
    }];
    forceSSL = false;
    enableACME = false;
    locations."/" = {
      proxyPass = "http://[::1]:${toString config.services.collabora-online.port}";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_set_header Host $host;
      '';
    };
  };


  # Systemd unit to set Collabora options using occ
  systemd.services.nextcloud-config-collabora = let
    inherit (config.services.nextcloud) occ;

    wopi_url = "http://[::1]:${toString config.services.collabora-online.port}";
    public_wopi_url = "https://docs.da.sereia.gay";
    wopi_allowlist = lib.concatStringsSep "," config.services.collabora-online.settings.storage.wopi.host;
  in {
    wantedBy = [ "multi-user.target" ];
    after = [ "nextcloud-setup.service" "coolwsd.service" ];
    requires = [ "coolwsd.service" ];
    script = ''
      ${occ}/bin/nextcloud-occ config:app:set richdocuments wopi_url --value ${lib.escapeShellArg wopi_url}
      ${occ}/bin/nextcloud-occ config:app:set richdocuments public_wopi_url --value ${lib.escapeShellArg public_wopi_url}
      ${occ}/bin/nextcloud-occ config:app:set richdocuments wopi_allowlist --value ${lib.escapeShellArg wopi_allowlist}
      ${occ}/bin/nextcloud-occ richdocuments:setup
    '';
    serviceConfig = {
      Type = "oneshot";
    };
  };

}