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
          sha256 = "3eac47853faee43c4156a03a3673b41f724e8a6a9feefa5b87b1e473fcba0aa6";
        };
        x86_64-darwin = {
          target = "x86_64-apple-darwin";
          sha256 = "4657b2abd9f33f447b40e5b11c266197ec68b2fbc75a192ea2893010af7f3c23";
        };
        x86_64-linux = {
          target = "x86_64-unknown-linux-gnu";
          sha256 = "f9cb6b0295dcb7f8f93ac6de2bb6ff0b20d550b746c5c58f0f61420272100e8d";
        };
        i686-linux = {
          target = "i686-unknown-linux-gnu";
          sha256 = "39efd304da47d62a13c3b1afcc702066df0032b76e90a0bb6922c8eff7afc949";
        };
      };
    in eachSystem (mapAttrsToList (n: v: n) systems) (system: {
      packages.default = with import nixpkgs { inherit system; };

        stdenv.mkDerivation rec {
          name = "publisher-${version}";
          version = "0.1.9";

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

          meta = {
            description = "Tool to publish & distribute CLI tools";
            homepage = "https://github.com/termapps/publisher";
            platforms = [ system ];
          };
        };
    });
}
