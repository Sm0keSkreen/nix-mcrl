# nix-mcrl

Nix flake for [mcrl](https://github.com/Sm0keSkreen/mcrl), the JVM agent that lifts
Minecraft's account chat restriction.

Just the jar, no environment setup:

```
nix profile install github:Sm0keSkreen/nix-mcrl
```

That puts `mcrl.jar` in the Nix store; you still need to point `JDK_JAVA_OPTIONS` at it
yourself (see the [mcrl README](https://github.com/Sm0keSkreen/mcrl#readme)), or use the
home-manager module below, which does that for you.

## home-manager

```nix
{
  inputs.mcrl.url = "github:Sm0keSkreen/nix-mcrl";

  outputs = { self, home-manager, mcrl, ... }: {
    homeConfigurations.you = home-manager.lib.homeManagerConfiguration {
      modules = [
        mcrl.homeManagerModules.default
        { programs.mcrl.enable = true; }
      ];
    };
  };
}
```

`home-manager switch` after bumping this flake's input is the whole upgrade step; the
jar's path only changes with the generation, not on every rebuild, so once
`JDK_JAVA_OPTIONS` is set there's nothing else to redo. Doesn't cover the
Realms/telemetry/profanity extras (those need `config.json`, not currently wired up
through this module); run the full installer once for that if you want them.
