{ self, ... }:
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
}
