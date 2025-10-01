{ config, pkgs, lib, inputs, ... }: {
  networking.firewall.allowedTCPPorts = [ 178 53 ];
  networking.firewall.allowedUDPPorts = [ 178 53 ];

  services.adguardhome = {
    enable = true;
    mutableSettings = false;
    openFirewall = true;
    host = "0.0.0.0";
    port = 178;

    settings = {
      http = {
        # You can select any ip and port, just make sure to open firewalls where needed
        address = "0.0.0.0:178";
      };
      dns = {
        bootstrap_dns = config.services.adguardhome.settings.dns.upstream_dns;
        upstream_dns = [
          "1.1.1.1"
          "2606:4700:4700::1111"
          "9.9.9.11"
          "2620:fe::11"
          # Uncomment the following to use a local DNS service (e.g. Unbound)
          # Additionally replace the address & port as needed
          # "127.0.0.1:5335"
        ];
      };
      filtering = {
        protection_enabled = true;
        filtering_enabled = true;
        parental_enabled = false;
        safe_search.enabled = false;
      };
      # The following notation uses map
      # to not have to manually create {enabled = true; url = "";} for every filter
      # This is, however, fully optional
      filters = map(url: { enabled = true; url = url; }) [
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_9.txt"  # The Big List of Hacked Malware Web Sites
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt"  # malicious url blocklist
        "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts" # AD blocking, hopefully adguard uses the same syntax as pihole
        "https://gist.githubusercontent.com/wassname/78eeaaad299dc4cddd04e372f20a9aa7/raw/36d217ab1d6e123d8fc2b39e48af8ca63e4d4ac8/LG%2520Smart-TV%2520Blocklist%2520Adlist%2520(for%2520PiHole)"
        "https://raw.githubusercontent.com/TheShawnMiranda/LG-TV-Ad-Block/refs/heads/master/list" # Block updates for LG TV (ads are already blocked by disagreeing to most of the Terms of Use (except to the minimum needed to homekit, which unfortunately also enables update notifications))
      ];
    };
  };
}
