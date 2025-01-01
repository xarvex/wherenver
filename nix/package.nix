{
  lib,
  pkgs,
  rustPlatform,
}:

let
  manifest = (pkgs.lib.importTOML ../Cargo.toml).package;
in
rustPlatform.buildRustPackage rec {
  inherit (manifest) version;

  pname = manifest.name;

  src = pkgs.lib.cleanSource ../.;
  cargoLock.lockFile = ../Cargo.lock;

  meta = {
    inherit (manifest) description;

    homepage = manifest.repository;
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ xarvex ];
    mainProgram = pname;
    platforms = lib.platforms.linux;
  };
}
