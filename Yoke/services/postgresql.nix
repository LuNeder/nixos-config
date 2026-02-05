{
  services.postgresql = {
    enable = true;
  };

  services.postgresqlBackup = {
    enable = true;
    location = "/mnt/pool1/PersonalFiles/Documentos/pgsql-bkp";
    backupAll = true;
    startAt = "*-*-* 01:50:00";
    compression = "zstd";
    compressionLevel = 10;
  };
}