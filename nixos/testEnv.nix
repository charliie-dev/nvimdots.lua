{
  inputs,
  pkgs,
  ...
}:
let
  testSettings =
    { config, ... }:
    {
      home = {
        username = "hm-user";
        homeDirectory = "/home/hm-user";
        stateVersion = config.home.version.release;
      };
      xdg.enable = true;
      programs = {
        home-manager.enable = true;
        git.enable = true;
        neovim.nvimdots = {
          enable = true;
          setBuildEnv = true;
          withBuildTools = true;
        };
      };
    };
in
inputs.home-manager.lib.homeManagerConfiguration {
  inherit pkgs;
  modules = [
    ./default.nix
    testSettings
  ];
}
