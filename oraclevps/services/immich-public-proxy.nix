{ pkgs, config, ... }: {
  services.immich-public-proxy = {
      enable = true;
      port = 2284;
      immichUrl = "http://100.64.0.9:2283";
      settings = {
        downloadOriginalPhoto = true;
        showGalleryTitle = true;
        showGalleryDescription = true;
        allowDownloadAll = 1;
        allowSlugLinks = true;
      };
  };
}
