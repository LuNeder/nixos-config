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
      
      dns = let
        upstreams = [
            "1.1.1.1"
            "2606:4700:4700::1111"
            "9.9.9.11"
            "2620:fe::11"
            # Uncomment the following to use a local DNS service (e.g. Unbound)
            # Additionally replace the address & port as needed
            # "127.0.0.1:5335"
          ];
      in
        {
          bootstrap_dns = upstreams;
          upstream_dns = upstreams;
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
      user_rules = [
        # More LG TV Update Blocking (https://gist.github.com/wassname/78eeaaad299dc4cddd04e372f20a9aa7?permalink_comment_id=5736137#gistcomment-5736137)
        "ad.lgappstv.com"
        "aic.api.lgtviot.com"
        "aic-gfts.lge.com"
        "aic.homeprv.lgtvcommon.com"
        "aic.lgtviot.com"
        "aic-ngfts.lge.com"
        "aic.nudge.lgtvcommon.com"
        "aic-op-lss.lgthinq.com"
        "aic.rdl.lgtvcommon.com"
        "aic.recommend.lgtvcommon.com"
        "aic.sports.lgtviot.com"
        "aic.wiseconfig.lgtvcommon.com"
        "cdpbeacon.lgtvcommon.com"
        "cdpsvc.lgtvcommon.com"
        "de.ad.lgsmartad.com"
        "de.info.lgsmartad.com"
        "de.lgrecommends.lgappstv.com"
        "de.lgtvsdp.com"
        "de.rdx2.lgtvsdp.com"
        "de.tvsdp.lgeapi.com"
        "eic.cdpbeacon.lgtvcommon.com"
        "eic.cdpsvc.lgtvcommon.com"
        "eic-gfts.lge.com"
        "eic.homeprv.lgtvcommon.com"
        "eic.lgtviot.com"
        "eic-ngfts.lge.com"
        "eic.nudge.lgtvcommon.com"
        "eic-ocp.lgtviot.com"
        "eic.rdl.lgtvcommon.com"
        "eic.recommend.lgtvcommon.com"
        "eic.sports.lgtviot.com"
        "eic.wiseconfig.lgtvcommon.com"
        "fr.ibs.lgappstv.com"
        "fr.rdx2.lgtvsdp.com"
        "fr.security.lgtvsdp.com"
        "homeprv.lgtvcommon.com"
        "ibis.lgappstv.com"
        "ibs.lgappstv.com"
        "info.lgsmartad.com"
        "kr.info.lgsmartad.com"
        "lgsmartad.com"
        "lgtvonline.lge.com"
        "lgtvsdp.com"
        "lss.lgthinq.com"
        "ngfts.lge.com"
        "nudge.lgtvcommon.com"
        "prov-lg.alphonso.tv"
        "qt2-kic.lgtviot.com"
        "qt2-ngfts.lge.com"
        "rdl.lgtvcommon.com"
        "rdx2.lgtvsdp.com"
        "recommend.lgtvcommon.com"
        "service.idsync.analytics.yahoo.com"
        "service.lgtvcommon.com"
        "smartshare.lgtvsdp.com"
        "snu.lge.com"
        "su-ssl.lge.com"
        "us.ad.lgsmartad.com"
        "us.emp.lgsmartplatform.com"
        "us.ibs.lgappstv.com"
        "us.info.lgsmartad.com"
        "us.lgeapi.com"
        "us.lgtvsdp.com"
        "us.rdx2.lgtvsdp.com"

        # Printer contacts this 2424 times in 12 hours
        "chat.avatar.ext.hp.com"
        "||ext.hp.com^"
      ];
    };
  };
}
