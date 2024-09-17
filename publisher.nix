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
          sha256 = "ffbdad1d6823a891112665c5d7cbe02520c1e700077d659aa97ac02f03aaa7fd";
        };
        x86_64-darwin = {
          target = "x86_64-apple-darwin";
          sha256 = "333f33504876ec4beff6bd6fb71b0a64bec5a9671aa362fb59e2deeaf232e1d8";
        };
        x86_64-linux = {
          target = "x86_64-unknown-linux-gnu";
          sha256 = "d212fb2d604ba500dab47121cf8fc2f7c2c4bd69b7300994e994358443f28611";
        };
        i686-linux = {
          target = "i686-unknown-linux-gnu";
          sha256 = "46be3582ee5ee8524bbd218986952f1920ebeaed94a19cf4f2bfcbeaa0586953";
        };
      };
    in eachSystem (mapAttrsToList (n: v: n) systems) (system: {
      packages.default = with import nixpkgs { inherit system; };

        stdenv.mkDerivation rec {
          name = "publisher-${version}";
          version = "0.1.8";

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
