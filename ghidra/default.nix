# Taken from nixpkgs pkgs/tools/security/ghidra/build.nix and updated a bit.

{ stdenv
, fetchzip
, fetchurl
, fetchFromGitHub
, lib
, gradle_7
, perl
, makeWrapper
, openjdk17
, unzip
, makeDesktopItem
, autoPatchelfHook
, icoutils
, xcbuild
, protobuf3_17
, libredirect
}:

let
  gradle = gradle_7;
  pkg_path = "$out/lib/ghidra";
  pname = "ghidra";
  version = "10.2.3";

  src = fetchFromGitHub {
    owner = "NationalSecurityAgency";
    repo = "Ghidra";
    rev = "Ghidra_${version}_build";
    sha256 = "sha256-YhjKRlFlF89H05NsTS69SB108rNiiWijvZZY9fR+Ebc=";
  };

  desktopItem = makeDesktopItem {
    name = "ghidra";
    exec = "ghidra";
    icon = "ghidra";
    desktopName = "Ghidra";
    genericName = "Ghidra Software Reverse Engineering Suite";
    categories = [ "Development" ];
  };

  patches = [
    ./01-protobuf.patch
    ./02-launch.patch
    ./03-xdg-basedir.patch
  ];

  # Adds a gradle step that downloads all the dependencies to the gradle cache.
  addResolveStep = ''
    cat >>build.gradle <<HERE
task resolveDependencies {
  doLast {
    project.rootProject.allprojects.each { subProject ->
      subProject.buildscript.configurations.each { configuration ->
        resolveConfiguration(subProject, configuration, "buildscript config \''${configuration.name}")
      }
      subProject.configurations.each { configuration ->
        resolveConfiguration(subProject, configuration, "config \''${configuration.name}")
      }
    }
  }
}
void resolveConfiguration(subProject, configuration, name) {
  if (configuration.canBeResolved) {
    logger.info("Resolving project {} {}", subProject.name, name)
    configuration.resolve()
  }
}
HERE
  '';

  # fake build to pre-download deps into fixed-output derivation
  # Taken from mindustry derivation.
  deps = stdenv.mkDerivation {
    pname = "${pname}-deps";
    inherit version src;

    inherit patches;
    postPatch = addResolveStep;

    nativeBuildInputs = [ gradle perl ] ++ lib.optional stdenv.isDarwin xcbuild;
    buildPhase = ''
      export HOME="$NIX_BUILD_TOP/home"
      mkdir -p "$HOME"
      export JAVA_TOOL_OPTIONS="-Duser.home='$HOME'"
      export GRADLE_USER_HOME="$HOME/.gradle"

      # First, fetch the static dependencies.
      gradle --no-daemon --info -Dorg.gradle.java.home=${openjdk17} -I gradle/support/fetchDependencies.gradle init

      # Then, fetch the maven dependencies.
      gradle --no-daemon --info -Dorg.gradle.java.home=${openjdk17} resolveDependencies
    '';
    # perl code mavenizes pathes (com.squareup.okio/okio/1.13.0/a9283170b7305c8d92d25aff02a6ab7e45d06cbe/okio-1.13.0.jar -> com/squareup/okio/okio/1.13.0/okio-1.13.0.jar)
    installPhase = ''
      find $GRADLE_USER_HOME/caches/modules-2 -type f -regex '.*\.\(jar\|pom\)' \
        | perl -pe 's#(.*/([^/]+)/([^/]+)/([^/]+)/[0-9a-f]{30,40}/([^/\s]+))$# ($x = $2) =~ tr|\.|/|; "install -Dm444 $1 \$out/maven/$x/$3/$4/$5" #e' \
        | sh
      cp -r dependencies $out/dependencies
    '';
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = "sha256-5Mukfkea5cyg9Y5tk+MKxWq2QT8JPkB81OyPLx+v8yc=";
  };

in stdenv.mkDerivation rec {
  inherit pname version src;

  nativeBuildInputs = [
    gradle unzip makeWrapper icoutils
  ] ++ lib.optional stdenv.isDarwin xcbuild;

  buildInputs = [ protobuf3_17 ];

  dontStrip = true;

  inherit patches;

  buildPhase = ''
    export HOME="$NIX_BUILD_TOP/home"
    mkdir -p "$HOME"
    export JAVA_TOOL_OPTIONS="-Duser.home='$HOME'"

    ln -s ${deps}/dependencies dependencies

    sed -i "s#mavenLocal()#mavenLocal(); maven { url '${deps}/maven' }#g" build.gradle

    gradle --offline --no-daemon --info -Dorg.gradle.java.home=${openjdk17} buildGhidra
  '';

  installPhase = ''
    mkdir -p "${pkg_path}" "$out/share/applications"

    ZIP=build/dist/$(ls build/dist)
    echo $ZIP
    unzip $ZIP -d ${pkg_path}
    f=("${pkg_path}"/*)
    mv "${pkg_path}"/*/* "${pkg_path}"
    rmdir "''${f[@]}"

    ln -s ${desktopItem}/share/applications/* $out/share/applications

    icotool -x "Ghidra/RuntimeScripts/Windows/support/ghidra.ico"
    rm ghidra_4_40x40x32.png
    for f in ghidra_*.png; do
      res=$(basename "$f" ".png" | cut -d"_" -f3 | cut -d"x" -f1-2)
      mkdir -pv "$out/share/icons/hicolor/$res/apps"
      mv "$f" "$out/share/icons/hicolor/$res/apps/ghidra.png"
    done;
  '';

  postFixup = ''
    mkdir -p "$out/bin"
    ln -s "${pkg_path}/ghidraRun" "$out/bin/ghidra"
    wrapProgram "${pkg_path}/support/launch.sh" \
      --set JAVA_HOME ${openjdk17.home} \
      --prefix PATH : ${lib.makeBinPath [ openjdk17 ]}
  '';

  meta = with lib; {
    description = "A software reverse engineering (SRE) suite of tools developed by NSA's Research Directorate in support of the Cybersecurity mission";
    homepage = "https://ghidra-sre.org/";
    platforms = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" ];
    sourceProvenance = with sourceTypes; [
      fromSource
      binaryBytecode  # deps
    ];
    license = licenses.asl20;
    maintainers = with maintainers; [ roblabla ];
  };

}
