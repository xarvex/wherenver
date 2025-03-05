{ pkgs, self, ... }:

let
  inherit (self.checks.${pkgs.system}) pre-commit;
in
pkgs.mkShell {
  nativeBuildInputs =
    pre-commit.enabledPackages
    ++ (with pkgs; [
      cargo
      rustc

      clippy
      rust-analyzer

      cargo-deny
      cargo-edit
      cargo-expand
      cargo-msrv
      cargo-udeps

      shellcheck
    ]);
  buildInputs = with pkgs; [
    direnv

    bash
    fish
    zsh
  ];

  env = {
    RUST_BACKTRACE = 1;
    RUST_SRC_PATH = pkgs.rustPlatform.rustLibSrc;
  };

  inherit (pre-commit) shellHook;
}
