{
  description = "wherenver";

  inputs = {
    devenv.url = "github:cachix/devenv";

    devenv-root = {
      url = "file+file:///dev/null";
      flake = false;
    };

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    nix2container = {
      url = "github:nlewo/nix2container";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    systems.url = "github:nix-systems/default-linux";
  };

  outputs =
    {
      flake-parts,
      nixpkgs,
      self,
      ...
    }@inputs:
    let
      inherit (nixpkgs) lib;
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ inputs.devenv.flakeModule ];

      systems = import inputs.systems;

      perSystem =
        { pkgs, ... }:
        let
          manifest = (pkgs.lib.importTOML ./Cargo.toml).package;
        in
        {
          packages = rec {
            default = name;

            name = pkgs.rustPlatform.buildRustPackage rec {
              inherit (manifest) version;

              pname = manifest.name;

              src = pkgs.lib.cleanSource ./.;
              cargoLock.lockFile = ./Cargo.lock;

              meta = {
                inherit (manifest) description;

                homepage = manifest.repository;
                license = lib.licenses.mit;
                maintainers = with lib.maintainers; [ xarvex ];
                mainProgram = pname;
                platforms = lib.platforms.linux;
              };
            };
          };

          devenv.shells = rec {
            default = rust;

            rust = {
              devenv.root =
                let
                  devenvRoot = builtins.readFile inputs.devenv-root.outPath;
                in
                # If not overriden (/dev/null), --impure is necessary.
                lib.mkIf (devenvRoot != "") devenvRoot;

              name = "wherenver";

              packages = with pkgs; [
                cargo-deny
                cargo-edit
                cargo-expand
                cargo-msrv
                cargo-udeps

                direnv
              ];

              languages = {
                nix.enable = true;
                rust = {
                  enable = true;
                  channel = "stable";
                };
                shell.enable = true;
              };

              pre-commit.hooks = {
                clippy.enable = true;
                deadnix.enable = true;
                flake-checker.enable = true;
                nixfmt-rfc-style.enable = true;
                rustfmt.enable = true;
                statix.enable = true;
              };
            };
          };

          formatter = pkgs.nixfmt-rfc-style;
        };

      flake.homeManagerModules = rec {
        default = wherenver;

        wherenver =
          {
            config,
            lib,
            pkgs,
            ...
          }:
          let
            cfg' = config.programs.direnv;
            cfg = cfg'.wherenver;
          in
          {
            options.programs.direnv.wherenver = {
              enable = lib.mkEnableOption "wherenver";
              enableBashIntegration = lib.mkEnableOption "Bash integration" // {
                default = true;
              };
              enableFishIntegration = lib.mkEnableOption "Fish integration" // {
                default = true;
              };
              package = lib.mkPackageOption self.packages.${pkgs.system} "wherenver" { };
            };

            config = lib.mkIf (cfg'.enable && cfg.enable) {
              programs = {
                bash.initExtra = lib.mkIf cfg.enableBashIntegration (
                  lib.mkOrder 1600 ''
                    eval "$(${lib.getExe cfg.package} hook bash)"
                  ''
                );
                fish.interactiveShellInit = lib.mkIf cfg.enableFishIntegration (
                  lib.mkOrder 1600 ''
                    ${lib.getExe cfg.package} hook fish | source
                  ''
                );
              };
            };
          };
      };
    };
}
