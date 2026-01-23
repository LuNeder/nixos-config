{ lib, ... }: {
  # This file was populated at runtime with the networking
  # details gathered from the active system.
  networking = {
    nameservers = [ "169.254.169.254" ];
    defaultGateway = "10.0.0.1";
    defaultGateway6 = {
      address = "fe80::200:17ff:fee5:90dd";
      interface = "ens3";
    };
    dhcpcd.enable = false;
    usePredictableInterfaceNames = lib.mkForce true;
    interfaces = {
      ens3 = {
        ipv4.addresses = [
          { address="10.0.0.14"; prefixLength=24; }
        ];
        ipv6.addresses = [
          { address="2603:c021:c00a:3300::33"; prefixLength=128; }
          { address="fe80::17ff:fe05:f577"; prefixLength=64; }
        ];
        ipv4.routes = [ { address = "10.0.0.1"; prefixLength = 32; } ];
        ipv6.routes = [ { address = "fe80::200:17ff:fee5:90dd"; prefixLength = 128; } ];
      };
      
    };
  };
  services.udev.extraRules = ''
    ATTR{address}=="02:00:17:05:f5:77", NAME="ens3"   
  '';
}
