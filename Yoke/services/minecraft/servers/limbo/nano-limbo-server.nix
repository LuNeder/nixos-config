{
  stdenv,
  fetchurl,
  jre_headless,
}:
stdenv.mkDerivation rec {
  pname = "nano-limbo";
  version = "1.13.0";
  src = fetchurl {
    url = "https://github.com/Nan1t/NanoLimbo/releases/download/v${version}/NanoLimbo.jar";
    sha256 = "sha256-iE3D1JQfsJZN/TSM68Zq+2krFWohPMmA1vR/AkQUMs8=";
  };
  preferLocalBuild = true;
  dontUnpack = true;
  installPhase = ''
    mkdir -p $out/bin $out/lib/minecraft
    cp -v $src $out/lib/minecraft/server.jar
    cat > $out/bin/${pname} << EOF
    #!/bin/sh
    exec ${jre_headless}/bin/java \$@ -jar $out/lib/minecraft/server.jar nogui
    EOF
    chmod +x $out/bin/${pname}
  '';

  meta.mainProgram = pname;
}
