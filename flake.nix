{
  description = "Packages patched with fixes to adjust configuration file/etc. locations.";

  outputs = { self }: {
    overlays.default =
      let
        addPatch =
          prev: patch: prev.overrideAttrs (prevAttrs: {
            patches = (prevAttrs.patches or [ ]) ++ [ patch ];
          });

      in

      final: prev: {
        act = addPatch prev.act ./act.patch;
        awscli2 = addPatch prev.awscli2 ./awscli2.patch;
        ghidra = final.callPackage ./ghidra { };
        libgphoto2 = addPatch prev.libgphoto2 ./libgphoto2.patch;
        mongosh = addPatch prev.mongosh ./mongosh.patch;
        openjdk11 = addPatch prev.openjdk11 ./openjdk-11u.patch;
        openjdk17 = addPatch prev.openjdk17 ./openjdk-17u.patch;
        openjdk19 = addPatch prev.openjdk19 ./openjdk-17u.patch;
        yarn = addPatch prev.yarn ./yarn.patch;
      };

    nixosModules.default = { pkgs, ... }: {
      nixpkgs.overlays = [ self.overlays.default ];
    };
  };
}
