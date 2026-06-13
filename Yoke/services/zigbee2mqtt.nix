{ config, pkgs, lib, inputs, ... }: {
  services.zigbee2mqtt = {
    enable = true;
    settings = {
      homeassistant = config.services.home-assistant.enable;
      permit_join = true;
      frontend = {
        enabled = true;
        port = 8971;
      };
      serial = {
        adapter = "ember";
        port = "/dev/serial/by-id/usb-SMLIGHT_SMLIGHT_SLZB-07Mg24_de365e62bd8aef11a9c21fccef8776e9-if00-port0";
        rtscts = true;
      };
      mqtt = {
        server = "mqtt://localhost:1883";
      };

    };
  };

  networking.firewall.allowedTCPPorts = [ 8971 ];

  services.nginx.virtualHosts."z2m.${config.var.fqdn}" = {
    forceSSL = true;
    sslCertificate = "${config.var.sslCertificate}";
    sslCertificateKey = "${config.var.sslCertificateKey}";
    extraConfig = ''
      client_max_body_size 30M;
    '';
    locations."/" = {
      proxyPass = "http://[::1]:${toString config.services.zigbee2mqtt.port}";
      proxyWebsockets = false;
    };
  };
}
