{
  description = "Tool to publish & distribute CLI tools";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    with flake-utils.lib;
    with nixpkgs.lib;

    let
      systems = {
        aarch64-darwin = {
          target = "aarch64-apple-darwin";
          sha256 = "4864edb0cef89f60aeda7d299341483c7a350e0435bceca8cc48b2ac695d9328";
        };
        x86_64-darwin = {
          target = "x86_64-apple-darwin";
          sha256 = "6208267af77a718d19f621c53d64fd45b6869d7651e359c315887702506fe008";
        };
        x86_64-linux = {
          target = "x86_64-unknown-linux-gnu";
          sha256 = "5e676ecaf211574851b73a0628b956f90ac55380055fa8007f5feb4193611d5d";
        };
        i686-linux = {
          target = "i686-unknown-linux-gnu";
          sha256 = "aae4c2d679c2206fcdb58143f6a08be6437bdab0bbc103b59de01525c72288ee";
        };
      };
    in eachSystem (mapAttrsToList (n: v: n) systems) (system: {
      packages.default = with import nixpkgs { inherit system; };

        stdenv.mkDerivation rec {
          name = "publisher-${version}";
          version = "0.1.5";

          nativeBuildInputs = [ unzip ];

          src = pkgs.fetchurl {
            url = "https://github.com/termapps/publisher/releases/download/v${version}/publisher-v${version}-${systems.${system}.target}.zip";
            inherit (systems.${system}) sha256;
          };

          sourceRoot = ".";

          installPhase = ''
            install -Dm755 publisher $out/bin/publisher
            install -Dm755 LICENSE $out/share/licenses/publisher/LICENSE
          '';

          meta = with lib; {
            description = "Tool to publish & distribute CLI tools";
            homepage = "https://github.com/termapps/publisher";
            platforms = [ system ];
          };
        };
    });
}
