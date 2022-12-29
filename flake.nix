{
  description = "Packages patched with fixes to adjust configuration file/etc. locations.";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: {
    overlays.default =
      let
        addPatch =
          prev: patch: prev.overrideAttrs (prevAttrs: {
            patches = (prevAttrs.patches or [ ]) ++ [ patch ];
          });

        noPkiDrv = final: final.stdenv.mkDerivation rec {
          name = "no.pki";

          unpackPhase = ''
            cp ${./no.pki.c} no.pki.c
          '';

          libName = "no.pki" + final.stdenv.hostPlatform.extensions.sharedLibrary;

          buildPhase = ''
            runHook preBuild
            $CC -Wall -O3 -fPIC no.pki.c -ldl -shared -o "$libName"
            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall
            install -vD "$libName" "$out/lib/$libName"
            runHook postInstall
          '';
        };

      in

      final: prev:
        let noPki = noPkiDrv final; in {
          act = addPatch prev.act ./act.patch;
          awscli2 = addPatch prev.awscli2 ./awscli2.patch;
          ghidra = final.callPackage ./ghidra { };
          libgphoto2 = addPatch prev.libgphoto2 ./libgphoto2.patch;
          mongosh = addPatch prev.mongosh ./mongosh.patch;
          openjdk11 = addPatch prev.openjdk11 ./openjdk-11u.patch;
          openjdk17 = addPatch prev.openjdk17 ./openjdk-17u.patch;
          openjdk19 = addPatch prev.openjdk19 ./openjdk-17u.patch;
          yarn = addPatch prev.yarn ./yarn.patch;
          slack = prev.slack.overrideAttrs (old: {
            installPhase = (old.installPhase or "") + ''
              mv $out/bin/slack $out/bin/.slack+pki
              makeWrapper $out/bin/.slack+pki $out/bin/slack \
                --set LD_PRELOAD ${noPki}/lib/${noPki.libName}
            '';
          });
          discord = prev.discord.overrideAttrs (old: {
            installPhase = (old.installPhase or "") + ''
              mv $out/bin/discord $out/bin/.discord+pki
              makeWrapper $out/bin/.discord+pki $out/bin/discord \
                --set LD_PRELOAD ${noPki}/lib/${noPki.libName}
            '';
          });
        };

    nixosModules.default = { pkgs, ... }: {
      nixpkgs.overlays = [ self.overlays.default ];
    };
  } // flake-utils.lib.eachDefaultSystem (system:
    let pkgs = import nixpkgs { inherit system; overlays = [ self.overlays.default ]; config.allowUnfree = true; };
    in {
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          nil
          rnix-lsp
          gnumake
          clang-tools
          slack
          discord
        ];

        nativeBuildInputs = with pkgs; [
          gcc
        ];
      };
    }
  );
}
