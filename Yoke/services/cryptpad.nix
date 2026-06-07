{ config, lib, pkgs, ... }: {
  services.cryptpad = {
    enable = true;
    configureNginx = false;

    settings = {
      httpUnsafeOrigin = "https://docs.da.sereia.gay";
      httpSafeOrigin = "https://sandbox-docs.da.sereia.gay";

      httpAddress = "::";
      httpPort = 3500;
      websocketPort = 3503;

      filePath = "/mnt/pool1/cryptpad";
      archivePath = "/mnt/pool1/cryptpad/data/archive";
      pinPath = "/mnt/pool1/cryptpad/pins";
      taskPath = "/mnt/pool1/cryptpad/tasks";
      blockPath = "/mnt/pool1/cryptpad/block";
      blobPath = "/mnt/pool1/cryptpad/blob";
      blobStagingPath = "/mnt/pool1/cryptpad/blobstage";
      decreePath = "/mnt/pool1/cryptpad/data/decrees";

      # Number of child processes (defaults to number of CPU cores if null)
      maxWorkers = null;

      # https://<your-cryptpad>/settings/
      adminKeys = [
        "[luana@docs.da.sereia.gay/mHkIjhjPQuSXCUKWl45CR09AsmkoPc1sLC+3GzTH+HE=]"
      ];
      logToStdout = true;
      logLevel = "info";

      # Telemetry
      blockDailyCheck = true;

      # Days of inactivity before unpinned pads expire (false to disable)
      inactiveTime = 2;

      # Days to retain archived data before permanent deletion
      archiveRetentionTime = 15;

      # Days an account can remain idle before its data is removed
      # Leave commented/null to preserve all user data regardless of inactivity
      accountRetentionTime = null;

      # Maximum upload size in bytes (default: 20MB)
      maxUploadSize = 0;

      # Maximum upload size for premium accounts (default: same as regular)
       premiumUploadSize = 10240;

      # enforceMFA = false;

      # Log IP addresses of users who modify documents (requires logLevel <= "info")
      logIP = true;
    };
  };

  # Fixed user for cryptpad (replaces DynamicUser)
  users.users.cryptpad = {
    isSystemUser = true;
    group = "cryptpad";
    home = "/mnt/pool1/cryptpad";
    createHome = false;
  };
  users.groups.cryptpad = {};

  # Override systemd service settings
  systemd.services.cryptpad = {
    confinement.enable = lib.mkForce false;

    serviceConfig = {
      # Use fixed user instead of DynamicUser
      DynamicUser = lib.mkForce false;
      User = lib.mkForce "cryptpad";
      Group = lib.mkForce "cryptpad";

      # Allow access to custom paths
      WorkingDirectory = lib.mkForce "/mnt/pool1/cryptpad";
      ReadWritePaths = [ "/mnt/pool1/cryptpad" ];
      NoNewPrivileges = lib.mkForce false;
      PrivateDevices = lib.mkForce false;
      ProtectSystem = lib.mkForce false;
    };
  };

  # Ensure all required directories exist with correct permissions
  systemd.tmpfiles.rules = [
    "d /mnt/pool1/cryptpad 0750 cryptpad cryptpad -"
    "d /mnt/pool1/cryptpad/data 0750 cryptpad cryptpad -"
    "d /mnt/pool1/cryptpad/data/archive 0750 cryptpad cryptpad -"
    "d /mnt/pool1/cryptpad/data/decrees 0750 cryptpad cryptpad -"
    "d /mnt/pool1/cryptpad/pins 0750 cryptpad cryptpad -"
    "d /mnt/pool1/cryptpad/tasks 0750 cryptpad cryptpad -"
    "d /mnt/pool1/cryptpad/block 0750 cryptpad cryptpad -"
    "d /mnt/pool1/cryptpad/blob 0750 cryptpad cryptpad -"
    "d /mnt/pool1/cryptpad/blobstage 0750 cryptpad cryptpad -"
  ];

  networking.firewall.allowedTCPPorts = [ 3500 3503 ];
  networking.firewall.allowedUDPPorts = [ 3500 3503 ];
}
