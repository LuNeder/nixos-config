{ config, pkgs, lib, inputs, ... }: {
  merpkgs.services.catask = {
    enable = true; # TODO: Fix python deps
   # package = pkgs.merpkgs.catask;
    listenAddress = "[::]";
    port = 8220;
    openFirewall = true;
    dotenvPath = config.sops.templates."cataskenv".path;
    configPath = config.sops.templates."cataskcfg".path;
  };

  sops.secrets = {
    appsecret.sopsFile = ./secrets.yaml;
    admpass.sopsFile = ./secrets.yaml;
    fediid.sopsFile = ./secrets.yaml;
    fedisecret.sopsFile = ./secrets.yaml;
    feditoken.sopsFile = ./secrets.yaml;
    cataskid.sopsFile = ./secrets.yaml;
    cataskapikey.sopsFile = ./secrets.yaml;
  };

  sops.templates."cataskenv" = {
    owner = config.merpkgs.services.catask.user;
    group = config.merpkgs.services.catask.group;
    content = ''
      DB_NAME = catask
      DB_USER = catask
      ADMIN_PASSWORD = '${config.sops.placeholder.admpass}'
      APP_SECRET = ${config.sops.placeholder.appsecret}
    '';
  };

  sops.templates."cataskcfg" = {
    owner = config.merpkgs.services.catask.user;
    group = config.merpkgs.services.catask.group;
    content = builtins.toJSON {
      accessibility = {
        font = "default";
        userway = {
          account = "";
          enabled = false;
        };
      };
      allowAnonQuestions = true;
      analyticsEnabled = false;
      anonName = "Anonymous";
      antispam = {
        enabled = true;
        type = "basic";
        "frc" = {
          "apikey" = "";
          "sitekey" = "";
        };
        "recaptcha" = {
          "secretkey" = "";
          "sitekey" = "";
        };
        "turnstile" = {
          "secretkey" = "";
          "sitekey" = "";
        };
      };
      charLimit = "1024";
      comments = {
        enabled = false; # causes confusion about where to ask questions
        style = "compact";
      };
      crosspost.bluesky.enabled = false;
      crosspost.fediverse = {
        accountInfo = {
          "display_name" = "\ud83c\udff3\ufe0f\u200d\ud83c\udf08\ud83c\udf83\ud83c\udde7\ud83c\uddf7Luana\ud83c\udde7\ud83c\uddf7\ud83c\udf83\ud83c\udff3\ufe0f\u200d\ud83c\udf08";
          username = "luana";
          avatarUrl = "https://media.wetdry.world/accounts/avatars/113/617/459/618/413/214/original/547d7495a454cb1f.png";
        };
        client = {
          id = "${config.sops.placeholder.fediid}";
          secret = "${config.sops.placeholder.fedisecret}";
        };
        cw = "AskMer (CatAsk)";
        enabled = true;
        instance = "wetdry.world";
        isMisskey = false;
        loggedIn = true;
        token = "${config.sops.placeholder.feditoken}";
        visibility = "private";
      };
        fediVerificationUrl = "https://wetdry.world/@luana";
        instance = {
          description = "Ask me something!";
          fullBaseUrl = "https://pergunte.pra.sereia.gay";
          image = "/static/icons/favicon/android-chrome-512x512.png";
          rules = "Be kind!";
          title = "AskMer";
          id = "${config.sops.placeholder.cataskid}";
          apiKey = "${config.sops.placeholder.cataskapikey}";
        };
        languages = {
          allowChanging = true;
          default = "en_US";
        };
        lockInbox = false;
        noDeleteConfirm = false;
        ntfy = {
          enabled = false;
          host = "";
          pass = "";
          topic = "";
          user = "";
        };
      plugins.enabled = false;
      sentry."report_level" = "0";
      oauth."providers_configured" = 0;
      setupCompleted = true;
      showQuestionCount = true;
      style = {
        accentDark = "#62d2dcff";
        accentLight = "#50bbb9ff";
        "bgDark" = "#351830ff";
        "bgLight" = "#ffa5dbff";
        "cardStyle" = "compact";
        "customCss" = "";
        "homepageLayout" = "catask";
        "infoBoxLayout" = "column";
        "navIcons" = true;
        "navIconsOnly" = false;
        "navStyle" = "pills";
        "overrideBaseStyles" = false;
        "overrideCatAskStyles" = false;
        "tintColors" = true;
        "useCustomCss" = false;

      };
      themeStoreUrl = "https://themes.catask.org";
      trimContentAfter = "150";
      username = "";
    };
  };
}

