{ pkgs, ... }:

pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    cargo
    rustc

    clippy
    rust-analyzer
    rustfmt

    cargo-deny
    cargo-edit
    cargo-expand
    cargo-msrv
    cargo-sort
    cargo-udeps

    shellcheck

    deadnix
    flake-checker
    nixfmt-rfc-style
    statix

    pre-commit
  ];
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

  shellHook = ''
    pre-commit install
  '';
}
