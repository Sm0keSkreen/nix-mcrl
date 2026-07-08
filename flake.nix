{
  description = "Lift Minecraft's account chat restriction across every loader/version";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
    in {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in {
          default = pkgs.stdenvNoCC.mkDerivation {
            pname = "mcrl";
            version = "1.3.3";
            src = pkgs.fetchurl {
              url = "https://github.com/Sm0keSkreen/mcrl/releases/download/v1.3.3/mcrl.jar";
              hash = "sha256-g4aDTcfN0n+XzriThl+18WJqTSxNp0uA/0RS398+HCA=";
            };
            dontUnpack = true;
            installPhase = ''
              mkdir -p $out/share/mcrl
              cp $src $out/share/mcrl/mcrl.jar
            '';
            meta = with pkgs.lib; {
              description = "Lift Minecraft's account chat restriction across every loader/version";
              homepage = "https://github.com/Sm0keSkreen/mcrl";
              license = licenses.mit;
              platforms = supportedSystems;
            };
          };
        });

      # config.json has to live in the same directory as the jar (that's how McrlConfig finds
      # it), but the jar itself lives in the read-only, immutable Nix store, so config.json can't
      # go there. Instead this symlinks the jar into a normal per-user path and writes
      # config.json declaratively next to that symlink; `home-manager switch` after bumping this
      # flake input or changing any programs.mcrl.* option is the whole "apply" step.
      homeManagerModules.default = { config, lib, pkgs, ... }:
        let
          cfg = config.programs.mcrl;
          jarStorePath = "${self.packages.${pkgs.system}.default}/share/mcrl/mcrl.jar";
          installedJarPath = "${config.home.homeDirectory}/.local/share/mcrl/mcrl.jar";
        in {
          options.programs.mcrl = {
            enable = lib.mkEnableOption "mcrl (lifts Minecraft's chat restriction)";
            extras = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Also unlock Realms, the multiplayer server list, and friends where the account API supports it.";
            };
            allowTelemetry = lib.mkOption {
              type = lib.types.nullOr lib.types.bool;
              default = null;
              description = "true/false to force telemetry on/off; null (default) leaves the account's existing setting alone.";
            };
            allowProfanityFilter = lib.mkOption {
              type = lib.types.nullOr lib.types.bool;
              default = null;
              description = "true/false to force the in-game chat profanity filter on/off; null (default) leaves the account's existing setting alone.";
            };
          };

          config = lib.mkIf cfg.enable {
            home.file.".local/share/mcrl/mcrl.jar".source = jarStorePath;
            home.file.".local/share/mcrl/config.json".text = builtins.toJSON {
              extras = cfg.extras;
              allowTelemetry = cfg.allowTelemetry;
              allowProfanityFilter = cfg.allowProfanityFilter;
            };
            home.sessionVariables.JDK_JAVA_OPTIONS = ''-javaagent:"${installedJarPath}"'';
          };
        };
    };
}
