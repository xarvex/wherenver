{
  description = "dotpanel";

  inputs = {
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    systems.url = "github:nix-systems/default-linux";
  };

  outputs =
    inputs@{
      flake-parts,
      nixpkgs,
      self,
      ...
    }:
    let
      inherit (nixpkgs) lib;
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;

      perSystem =
        { pkgs, system, ... }:
        {
          packages = rec {
            default = wherenver;
            wherenver = pkgs.callPackage ./nix/package.nix { };
          };

          devShells = rec {
            default = wherenver;
            wherenver = import ./nix/shell.nix {
              inherit
                inputs
                lib
                pkgs
                self
                ;
            };
          };

          checks.pre-commit = inputs.git-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              clippy.enable = true;
              deadnix.enable = true;
              flake-checker.enable = true;
              nixfmt-rfc-style.enable = true;
              rustfmt.enable = true;
              statix.enable = true;
            };
          };

          formatter = pkgs.nixfmt-rfc-style;
        };

      flake.homeManagerModules = rec {
        default = wherenver;
        wherenver = import ./nix/home-manager.nix { inherit inputs self; };
      };
    };
}
