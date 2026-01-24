{ pkgs, config, ... }: {
  services.oink = {
    enable = true;
    apiKeyFile = config.sops.secrets.porkbunapi.path;
    secretApiKeyFile = config.sops.secrets.porkbunsecret.path;
    domains = [
      {
        domain = "sereia.gay";
        subdomain = "*.rp";
      }
      {
        domain = "sereia.gay";
        subdomain = "ask";
      }
      {
        domain = "sereia.gay";
        subdomain = "*.pra";
      }
    ];
  };

  sops.secrets = {
    porkbunapi.sopsFile = ../secrets.yaml;
    porkbunsecret.sopsFile = ../secrets.yaml;
  };
}
