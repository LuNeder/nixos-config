{ config, pkgs, lib, inputs, ... }: {
  services.unbound = {
    enable = true;

    user = "unbound"; # default
    group = "unbound"; # default 

    # Useful: https://docs.pi-hole.net/guides/dns/unbound/
    settings = {
      server = {
        interface = "::1";
        port = 5335;
        do-ip6 = true;
        prefer-ip6 = true;
        do-ip4 = true;
        do-tcp = true;
        do-udp = true;
        prefetch =  true;
        num-threads = 1;

        # OpenNIC
        # root-hints = "/var/lib/unbound/opennic.hint"; # uhhh yeah that didn't work

        # Don't use Capitalization randomization as it known to cause DNSSEC issues sometimes
        # see https://discourse.pi-hole.net/t/unbound-stubby-or-dnscrypt-proxy/9378 for further details
        use-caps-for-id = false;

        # Reduce EDNS reassembly buffer size.
        # IP fragmentation is unreliable on the Internet today, and can cause
        # transmission failures when large DNS messages are sent via UDP. Even
        # when fragmentation does work, it may not be secure; it is theoretically
        # possible to spoof parts of a fragmented DNS message, without easy
        # detection at the receiving end. Recently, there was an excellent study
        # >>> Defragmenting DNS - Determining the optimal maximum UDP response size for DNS <<<
        # by Axel Koolhaas, and Tjeerd Slokker (https://indico.dns-oarc.net/event/36/contributions/776/)
        # in collaboration with NLnet Labs explored DNS using real world data from the
        # the RIPE Atlas probes and the researchers suggested different values for
        # IPv4 and IPv6 and in different scenarios. They advise that servers should
        # be configured to limit DNS messages sent over UDP to a size that will not
        # trigger fragmentation on typical network links. DNS servers can switch
        # from UDP to TCP when a DNS response is too big to fit in this limited
        # buffer size. This value has also been suggested in DNS Flag Day 2020.
        edns-buffer-size = 1232;

        # Ensure kernel buffer is large enough to not lose messages in traffic spikes
        so-rcvbuf = "1m";

        # Ensure privacy of local IP ranges
        private-address = [
          # Ensure privacy of local IP ranges
          "192.168.0.0/16"
          "169.254.0.0/16"
          "172.16.0.0/12"
          "10.0.0.0/8"
          "fd00::/8"
          "fe80::/10"

          # Ensure no reverse queries to non-public IP ranges (RFC6303 4.2)
          "192.0.2.0/24"
          "198.51.100.0/24"
          "203.0.113.0/24"
          "255.255.255.255/32"
          "2001:db8::/32"
        ];
      };
    };
  };

  # OpenNIC root servers DNS hint grabber
    systemd.services = {
    "opennic-root-hint" = {
      path = [ pkgs.brush pkgs.dig ];
      restartIfChanged = false;
      serviceConfig = {
        Type = "oneshot";
        User = "unbound";
        RemainAfterExit = false;
        ExecStart = pkgs.writeScript "binary-cache-updater" ''
          #!/usr/bin/env brush

          # I know OpenNIC's root servers also respond for ICANN TLDs, but wonder if it's possible to merge this hints list with ICANN's one instead, hmmm...

          HINTPATH='/var/lib/unbound/opennic.hint'

          touch $HINTPATH
          \cp -f $HINTPATH $HINTPATH.bkp

          {
            # ns0.opennic.glue.
            dig . NS @168.119.153.26 > $HINTPATH
          } || {
            # ns2.opennic.glue.
            dig . NS @161.97.219.84 > $HINTPATH
          } || {
            # If both fail, restore previous
            \cp -f $HINTPATH.bkp $HINTPATH
          }
        '';
      };
    };
  };

  systemd.timers."opennic-root-hint" = {
    wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*-*-* 01:00:00 America/Sao_Paulo";
        Unit = "opennic-root-hint.service";
      };
  };

  networking.firewall.allowedTCPPorts = [ config.services.unbound.settings.server.port ];
  networking.firewall.allowedUDPPorts = [ config.services.unbound.settings.server.port ];
}