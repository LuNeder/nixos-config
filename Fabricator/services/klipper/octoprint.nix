{
  services.klipper.octoprintIntegration = true;
  services.octoprint = {
    enable = true;
    openFirewall = true;
    plugins = plugins: with plugins; [ themeify stlviewer octoklipper ];
    extraConfig = {
      serial = {
        additionalPorts = [ "~/printer_data/comms/klippy.serial" ];
      };
      plugins = {
        klipper = {
          
        };
      };
      webcam = {
        stream = "http://100.64.0.5/webcam";
      };
      feature = {
        sdSupport = true;
      };
      folder = {
        uploads = "/media/3DPrinter/gcodes";
        timelapse = "/media/3DPrinter/timelapses";
        timelapse_tmp = "/media/3DPrinter/timelapses/tmp";
      };
    };
  };
}