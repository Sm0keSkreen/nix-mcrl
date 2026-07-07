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
            version = "1.3.0";
            src = pkgs.fetchurl {
              url = "https://github.com/Sm0keSkreen/mcrl/releases/download/v1.3.0/mcrl.jar";
              hash = "sha256-Wu9Fgi2Gsq34zPrh4By3gLwid44i03tGpCoAX4eK2a0=";
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

      # Sets JDK_JAVA_OPTIONS for home-manager users; `home-manager switch` after bumping this
      # flake input is the whole "upgrade" step, since the store path is fixed per generation.
      homeManagerModules.default = { config, lib, pkgs, ... }: {
        options.programs.mcrl.enable = lib.mkEnableOption "mcrl (lifts Minecraft's chat restriction)";
        config = lib.mkIf config.programs.mcrl.enable {
          home.packages = [ self.packages.${pkgs.system}.default ];
          home.sessionVariables.JDK_JAVA_OPTIONS =
            ''-javaagent:"${self.packages.${pkgs.system}.default}/share/mcrl/mcrl.jar"'';
        };
      };
    };
}
