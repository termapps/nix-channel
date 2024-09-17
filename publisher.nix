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
          sha256 = "a86a1b36e3d5088cb2add00ca1853e91695c267ccd239023c6eacaac1191ad1e";
        };
        x86_64-darwin = {
          target = "x86_64-apple-darwin";
          sha256 = "206b8f9808dd7169aa9c8fd732c5509e56669bff4641c1d838908623fd854604";
        };
        x86_64-linux = {
          target = "x86_64-unknown-linux-gnu";
          sha256 = "1a85a6d0fdedb39065da34ecfafc281584710632cde9e98a4481f964098c62ad";
        };
        i686-linux = {
          target = "i686-unknown-linux-gnu";
          sha256 = "c97215a094c44e3a0aa8d698d3105f7dd801fbb9373605fc1c7d580c6fa4e938";
        };
      };
    in eachSystem (mapAttrsToList (n: v: n) systems) (system: {
      packages.default = with import nixpkgs { inherit system; };

        stdenv.mkDerivation rec {
          name = "publisher-${version}";
          version = "0.1.7";

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
