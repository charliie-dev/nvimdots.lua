# home-manager module of neovim setup
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.neovim.nvimdots;
  inherit (lib.attrsets) optionalAttrs;
  inherit (lib.lists) optionals;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.strings) concatStringsSep versionOlder versionAtLeast;
  inherit (lib.types) listOf package;
in
{
  options = {
    programs.neovim = {
      nvimdots = {
        enable = mkEnableOption ''
          Activate the charliie-dev/nvimdots.lua Neovim configuration.
          See https://github.com/charliie-dev/nvimdots.lua for details.
        '';
        setBuildEnv = mkEnableOption ''
          Sets environment variables that resolve build dependencies for native plugins and `nvim-treesitter`.
          Environment variables are only visible to `nvim` and have no effect on any parent sessions.
          Required for NixOS.
        '';
        withBuildTools = mkEnableOption ''
          Include basic build tools like `gcc` and `pkg-config`.
          Required for NixOS.
        '';
        extraDependentPackages = mkOption {
          type = listOf package;
          default = [ ];
          example = literalExpression "[ pkgs.openssl ]";
          description = "Extra build depends to add `LIBRARY_PATH` and `CPATH`.";
        };
      };
    };
  };
  config =
    let
      # Inspired from https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/programs/nix-ld.nix
      build-dependent-pkgs =
        builtins.filter (package: !package.meta.unsupported) [
          # manylinux
          pkgs.acl
          pkgs.attr
          pkgs.bzip2
          pkgs.curl
          pkgs.glibc
          pkgs.libsodium
          pkgs.libssh
          pkgs.libxml2
          pkgs.openssl
          pkgs.stdenv.cc.cc
          pkgs.stdenv.cc.cc.lib
          pkgs.systemd
          pkgs.util-linux
          pkgs.xz
          pkgs.zlib
          pkgs.zstd
          # Packages not included in `nix-ld`'s NixOSModule
          pkgs.glib
          pkgs.libcxx
        ]
        ++ cfg.extraDependentPackages;

      neovim-build-deps = pkgs.buildEnv {
        name = "neovim-build-deps";
        paths = build-dependent-pkgs;
        extraOutputsToInstall = [ "dev" ];
        pathsToLink = [
          "/lib"
          "/include"
        ];
        ignoreCollisions = true;
      };
      pkgConfigPath = "${neovim-build-deps}/lib/pkgconfig";

      buildEnv = [
        "CPATH=\${CPATH:+\${CPATH}:}${neovim-build-deps}/include"
        "CPLUS_INCLUDE_PATH=\${CPLUS_INCLUDE_PATH:+\${CPLUS_INCLUDE_PATH}:}${neovim-build-deps}/include/c++/v1"
        "LD_LIBRARY_PATH=\${LD_LIBRARY_PATH:+\${LD_LIBRARY_PATH}:}${neovim-build-deps}/lib"
        "LIBRARY_PATH=\${LIBRARY_PATH:+\${LIBRARY_PATH}:}${neovim-build-deps}/lib"
        "NIX_LD_LIBRARY_PATH=\${NIX_LD_LIBRARY_PATH:+\${NIX_LD_LIBRARY_PATH}:}${neovim-build-deps}/lib"
        "PKG_CONFIG_PATH=\${PKG_CONFIG_PATH:+\${PKG_CONFIG_PATH}:}${pkgConfigPath}"
      ];
    in
    mkIf cfg.enable {
      xdg.configFile = {
        "nvim/init.lua".source = ../../init.lua;
        "nvim/lua".source = ../../lua;
        "nvim/snips".source = ../../snips;
      };
      home = {
        packages = [
          pkgs.ripgrep
        ];
        shellAliases = optionalAttrs (cfg.setBuildEnv && (versionOlder config.home.stateVersion "24.05")) {
          nvim = concatStringsSep " " buildEnv + " nvim";
        };
      };
      programs.neovim = {
        enable = true;

        withNodeJs = true;
        withPython3 = true;

        extraPackages = [
          # Dependent packages used by default plugins
          pkgs.tree-sitter
        ]
        ++ optionals cfg.withBuildTools [
          pkgs.cargo
          pkgs.clang
          pkgs.cmake
          pkgs.gcc
          pkgs.gnumake
          pkgs.go
          pkgs.ninja
          pkgs.pkg-config
          pkgs.yarn
        ];
      }
      // optionalAttrs (versionAtLeast config.home.stateVersion "24.05") {
        extraWrapperArgs = optionals cfg.setBuildEnv [
          "--suffix"
          "CPATH"
          ":"
          "${neovim-build-deps}/include"
          "--suffix"
          "CPLUS_INCLUDE_PATH"
          ":"
          "${neovim-build-deps}/include/c++/v1"
          "--suffix"
          "LD_LIBRARY_PATH"
          ":"
          "${neovim-build-deps}/lib"
          "--suffix"
          "LIBRARY_PATH"
          ":"
          "${neovim-build-deps}/lib"
          "--suffix"
          "PKG_CONFIG_PATH"
          ":"
          "${pkgConfigPath}"
          "--suffix"
          "NIX_LD_LIBRARY_PATH"
          ":"
          "${neovim-build-deps}/lib"
        ];
      };
    };
}
