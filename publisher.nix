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
          sha256 = "1ba61d9c735e28b76c1845fe9ff38b9e02ea489b63998208efd8e4e57aa9875c";
        };
        x86_64-darwin = {
          target = "x86_64-apple-darwin";
          sha256 = "8618249b570f94f9c4023b4ae1fe660997074f6cb1e3afad60d3113871ff4f96";
        };
        x86_64-linux = {
          target = "x86_64-unknown-linux-gnu";
          sha256 = "593346067c1e3db8efa4b7ebd5474183e5f5aff0b06b27bd49e1d7b4683204c3";
        };
        i686-linux = {
          target = "i686-unknown-linux-gnu";
          sha256 = "bc8d9abfba1867188c5c86186d87fe1f277390dab625dd354a58db9082b0e2a1";
        };
      };
    in eachSystem (mapAttrsToList (n: v: n) systems) (system: {
      packages.default = with import nixpkgs { inherit system; };

        stdenv.mkDerivation rec {
          name = "publisher-${version}";
          version = "0.1.6";

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
