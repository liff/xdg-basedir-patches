{
  description = "Packages patched with fixes to adjust configuration file/etc. locations.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: {
    overlays.default =
      let
        addPatch =
          prev: patch: prev.overrideAttrs (prevAttrs: {
            patches = (prevAttrs.patches or [ ]) ++ [ patch ];
          });

        fixJavaHome =
          prev: final: prev.overrideAttrs (old: {
            passthru = old.passthru // { home = "${final}/lib/openjdk"; };
          });

        noPkiDrv = final: final.stdenv.mkDerivation {
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
          #awscli2 = addPatch prev.awscli2 ./awscli2.patch;

          discord = prev.discord.overrideAttrs (old: {
            installPhase = (old.installPhase or "") + ''
              mv $out/bin/discord $out/bin/.discord+pki
              makeWrapper $out/bin/.discord+pki $out/bin/discord \
                --prefix LD_PRELOAD : ${noPki}/lib/${noPki.libName}
            '';
          });

          #libgphoto2 = addPatch prev.libgphoto2 ./libgphoto2.patch;

          #openjdk11 = fixJavaHome (addPatch prev.openjdk11 ./openjdk-11u.patch) final.openjdk11;
          #openjdk11_headless = fixJavaHome (addPatch prev.openjdk11_headless ./openjdk-11u.patch) final.openjdk11_headless;
          #openjdk17 = fixJavaHome (addPatch prev.openjdk17 ./openjdk-17u-xdg.patch) final.openjdk17;
          #openjdk17_headless = fixJavaHome (addPatch prev.openjdk17_headless ./openjdk-17u-xdg.patch) final.openjdk17_headless;
          #openjdk19 = fixJavaHome (addPatch prev.openjdk19 ./openjdk-17u-xdg.patch) final.openjdk19;
          #openjdk19_headless = fixJavaHome (addPatch prev.openjdk19_headless ./openjdk-17u-xdg.patch) final.openjdk19_headless;
          #openjdk20 = fixJavaHome (addPatch prev.openjdk20 ./openjdk-20u-xdg.patch) final.openjdk20;
          #openjdk20_headless = fixJavaHome (addPatch prev.openjdk20_headless ./openjdk-20u-xdg.patch) final.openjdk20_headless;
          #openjdk21 = fixJavaHome (addPatch prev.openjdk21 ./openjdk-21u-xdg.patch) final.openjdk21;
          #openjdk21_headless = fixJavaHome (addPatch prev.openjdk21_headless ./openjdk-21u-xdg.patch) final.openjdk21_headless;

          jetbrains = prev.jetbrains // {
            #jdk = fixJavaHome (addPatch prev.jetbrains.jdk ./openjdk-21u-xdg.patch) final.jetbrains.jdk;
            rust-rover = prev.jetbrains.rust-rover.overrideAttrs (old: {
              preFixup = (old.preFixup or "") + ''
                gappsWrapperArgs+=(--prefix LD_PRELOAD : ${noPki}/lib/${noPki.libName})
              '';
            });
          };

          signal-desktop = prev.signal-desktop.overrideAttrs (old: {
            installPhase = (old.installPhase or "") + ''
              mv $out/bin/signal-desktop $out/bin/.signal-desktop+pki
              makeWrapper $out/bin/.signal-desktop+pki $out/bin/signal-desktop \
                --prefix LD_PRELOAD : ${noPki}/lib/${noPki.libName}
            '';
          });

          slack = prev.slack.overrideAttrs (old: {
            installPhase = (old.installPhase or "") + ''
              mv $out/bin/slack $out/bin/.slack+pki
              makeWrapper $out/bin/.slack+pki $out/bin/slack \
                --prefix LD_PRELOAD : ${noPki}/lib/${noPki.libName}
            '';
          });

          spotify = prev.spotify.overrideAttrs (old: {
            installPhase = (old.installPhase or "") + ''
              mv $out/bin/spotify $out/bin/.spotify+pki
              makeWrapper $out/bin/.spotify+pki $out/bin/spotify \
                --prefix LD_PRELOAD : ${noPki}/lib/${noPki.libName}
            '';
          });

          terraform = addPatch prev.terraform ./terraform.patch;

          vscode = prev.vscode.overrideAttrs (old: {
            postInstall = (old.postInstall or "") + ''
              mv $out/bin/code $out/bin/.code+pki
              makeWrapper $out/bin/.code+pki $out/bin/code \
                --prefix LD_PRELOAD : ${noPki}/lib/${noPki.libName}
            '';
          });

          # yarn = addPatch prev.yarn ./yarn.patch;

        } // (if prev ? intellij-idea-ultimate then {
          intellij-idea-ultimate = prev.intellij-idea-ultimate.overrideAttrs (old: {
            preFixup = (old.preFixup or "") + ''
              gappsWrapperArgs+=(--prefix LD_PRELOAD : ${noPki}/lib/${noPki.libName})
            '';
          });
        } else {}) // (if prev ? intellij-idea-community then {
          intellij-idea-community = prev.intellij-idea-community.overrideAttrs (old: {
            preFixup = (old.preFixup or "") + ''
              gappsWrapperArgs+=(--prefix LD_PRELOAD : ${noPki}/lib/${noPki.libName})
            '';
          });
        } else {});

    nixosModules.default = { pkgs, ... }: {
      imports = [ ./session-variables.nix ];
      nixpkgs.overlays = [ self.overlays.default ];
    };
  } // flake-utils.lib.eachDefaultSystem (system:
    let pkgs = import nixpkgs { inherit system; overlays = [ self.overlays.default ]; config.allowUnfree = true; };
    in {
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          nil
          gnumake
          clang-tools
          (python3.withPackages (pyPkgs: with pyPkgs; [
            black
            isort
            pylint
            bandit
            autopep8
            flake8
            mypy
          ]))
        ];

        nativeBuildInputs = with pkgs; [
          gcc
        ];
      };

      devShells.use = pkgs.mkShell {
        packages = with pkgs; [
          act
          awscli2
          discord
          ghidra
          gphoto2
          #openjdk11
          #openjdk17
          #openjdk19
          openjdk20
          mongosh
          signal-desktop
          slack
          terraform
          yarn
          zoom-us
        ];
      };
    }
  );
}
