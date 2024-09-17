{
  description = "Nix packages for Terminal Applications";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    with flake-utils.lib;
    with nixpkgs.lib.attrsets;
    with nixpkgs.lib.strings;

    eachSystem allSystems (system:
      let
        files = mapAttrsToList (n: v: ./. + "/${n}") (filterAttrs
          (n: v: v == "regular" && n != "flake.nix" && hasSuffix ".nix" n)
          (builtins.readDir ./.));
        pkgs = map (p:
          let
            pkg = ((import p).outputs {
              inherit self;
              inherit nixpkgs;
              inherit flake-utils;
            }).packages;
          in if hasAttr system pkg then {
            name = removeSuffix ".nix" (baseNameOf p);
            value = (getAttr system pkg).default;
          } else
            null) files;
      in { packages = listToAttrs (filter (p: p != null) pkgs); });
}
