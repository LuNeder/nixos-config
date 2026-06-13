{ config, pkgs, lib, inputs, ... }: {
  services.wyoming = {
    faster-whisper.servers."${config.networking.hostName}-whisper" = {
      enable = true;
      zeroconf.enable = true;
      uri = "tcp://0.0.0.0:10300";
      device = "auto";
      language = "pt";
      model = "turbo";
      beamSize = 10;
    };
    #faster-whisper.servers."${config.networking.hostName}-whisper-en" = {
    #  enable = true;
    #  zeroconf.enable = true;
    #  uri = "tcp://0.0.0.0:10301";
    #  device = "auto";
    #  language = "en";
    #  model = "turbo";
    #};
    #faster-whisper.servers."${config.networking.hostName}-whisper-fr" = {
    #  enable = true;
    #  zeroconf.enable = true;
    #  uri = "tcp://0.0.0.0:10302";
    #  device = "auto";
    #  language = "fr";
    #  model = "turbo";
    #};

    piper.servers."${config.networking.hostName}-piper" = {
      enable = true;
      zeroconf.enable = true;
      uri = "tcp://0.0.0.0:10200";
      voice = "pt_BR-jeff-medium"; # Also (only a single server is needed): fr_FR-upmc-medium, en_GB-semaine-medium (ou alan)
    };
    #piper.servers."${config.networking.hostName}-piper-en" = {
    #  enable = true;
    #  zeroconf.enable = true;
    #  uri = "tcp://0.0.0.0:10201";
    #  voice = "en_GB-semaine-medium"; # or alan
    #  speaker = 0;
    #};
    #piper.servers."${config.networking.hostName}-piper-fr" = {
    #  enable = true;
    #  zeroconf.enable = true;
    #  uri = "tcp://0.0.0.0:10202";
    #  voice = "fr_FR-upmc-medium";
    #  speaker = 0;
    #};
  };
}