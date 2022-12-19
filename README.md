Patches to fix application directory layouts. That is, replace 
`$HOME/.something` with the appropriate `$XDG_<some>_HOME/something`.

# Usage

```nix
{
  inputs.xdg-basedir-patches.url = "github:liff/xdg-basedir-patches";

  outputs = { self, xdg-basedir-patches }: {
    # replace 'joes-desktop' with your hostname here.
    nixosConfigurations.joes-desktop = nixpkgs.lib.nixosSystem {
      modules = [
        xdg-basedir-patches.nixosModules.default
      ];
    };
  };
}
```
