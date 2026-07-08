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
        {
          programs.mcrl = {
            enable = true;
            extras = true;                # Realms/servers/friends; default false
            allowTelemetry = false;        # true/false forces it; default null = leave alone
            allowProfanityFilter = false;  # same
          };
        }
      ];
    };
  };
}
```

`home-manager switch` after bumping this flake's input, or after changing any
`programs.mcrl.*` option, is the whole apply/upgrade step. `config.json` is generated
declaratively from `extras`/`allowTelemetry`/`allowProfanityFilter` (all optional;
`allowTelemetry`/`allowProfanityFilter` default to `null`, meaning leave the account's
existing setting alone rather than force it either way), so there's no separate script
to run for the Realms/telemetry/profanity extras, unlike the other package managers.
