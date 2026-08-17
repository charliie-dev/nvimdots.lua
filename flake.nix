{
  description = "Home Manager module for charliie-dev/nvimdots.lua";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    devshell.url = "github:numtide/devshell";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.devshell.flakeModule
      ];
      flake.homeManagerModules.default = ./nixos;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      perSystem =
        {
          pkgs,
          self',
          system,
          ...
        }:
        {
          formatter = pkgs.nixfmt;
          checks.nvim-build-env = pkgs.runCommand "check-nvim-build-env" { } ''
            export HOME="$TMPDIR/home"
            export XDG_CONFIG_HOME="$TMPDIR/config"
            export XDG_DATA_HOME="$TMPDIR/data"
            export XDG_STATE_HOME="$TMPDIR/state"
            export XDG_CACHE_HOME="$TMPDIR/cache"
            mkdir -p "$HOME" "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME" "$XDG_CACHE_HOME"
            ${self'.packages.testEnv}/home-path/bin/nvim -u NONE -i NONE --headless \
              '+lua local function check(ok,msg) if not ok then vim.api.nvim_err_writeln(msg); vim.cmd("cquit 1") end end; local values={CPATH="neovim-build-deps/include",LIBRARY_PATH="neovim-build-deps/lib"}; for name,needle in pairs(values) do check((vim.env[name] or ""):find(needle,1,true),name .. " missing " .. needle) end; local pkg=vim.env.PKG_CONFIG_PATH or ""; local root=vim.iter(vim.split(pkg,":",{plain=true})):find(function(path) return path:find("neovim-build-deps/lib/pkgconfig",1,true) ~= nil end); check(root and vim.fn.isdirectory(root)==1,"pkg-config metadata root missing"); check(vim.fn.executable("pkg-config")==1,"pkg-config executable missing"); local result=vim.system({"pkg-config","--exists","openssl"}):wait(); check(result.code==0,"pkg-config cannot resolve openssl: " .. (result.stderr or ""))' \
              '+qa!'
            touch "$out"
          '';
          packages = {
            testEnv = (import ./nixos/testEnv.nix { inherit inputs pkgs; }).activationPackage;
            check-linker = pkgs.writeShellApplication {
              name = "check-linker";
              text =
                let
                  ldd_cmd = if pkgs.stdenv.isDarwin then "xcrun otool -L" else "${pkgs.glibc.bin}/bin/ldd";
                in
                ''
                  #shellcheck disable=SC1090
                  source <(sed -ne :1 -e 'N;1,1b1' -e 'P;D' "${self.packages.${system}.testEnv}/home-path/bin/nvim")
                  echo "Checking files under ''${XDG_DATA_HOME}/''${NVIM_APPNAME:-nvim}/mason/bin..."
                  find "''${XDG_DATA_HOME}/''${NVIM_APPNAME:-nvim}/mason/bin" -type l | while read -r link; do
                    "${ldd_cmd}" "$(readlink -f "$link")" > /dev/zero 2>&1 || continue
                    linkers=$("${ldd_cmd}" "$(readlink -f "$link")" | tail -n+2)
                    echo "$linkers" | while read -r line; do
                      [ -z "$line" ] && continue
                      echo "$line" | grep -q "/nix/store" || printf '%s: %s does not link to /nix/store \n' "$(basename "$link")" "$line"
                    done
                  done
                  echo "*** Done ***"
                '';
            };
          };
          devshells.default = {
            commands = [
              {
                help = "neovim linked to testEnv.";
                name = "nvim";
                command = ''
                  ${self.packages.${system}.testEnv}/home-path/bin/nvim
                '';
              }
              {
                help = "check-linker";
                package = self.packages.${system}.check-linker;
              }
            ];
            devshell = {
              motd = ''
                {202}🔨 Welcome to devshell{reset}
                Symlink configs to "''${XDG_CONFIG_HOME}"/nvimdots!
                And NVIM_APPNAME=nvimdots is already configured, so neovim will put files under "\$XDG_xxx_HOME"/nvimdots.
                To uninstall, remove "\$XDG_xxx_HOME"/nvimdots.

                $(type -p menu &>/dev/null && menu)
              '';
              startup = {
                mkNvimDir = {
                  text = ''
                    mkdir -p "''${XDG_CONFIG_HOME}"/nvimdots
                    for path in lazy-lock.json init.lua lua snips; do
                      ln -sf "''${PWD}/''${path}" "''${XDG_CONFIG_HOME}"/nvimdots/
                    done
                  '';
                };
              };
            };
            env = [
              {
                name = "NVIM_APPNAME";
                value = "nvimdots";
              }
              {
                name = "PATH";
                prefix = "${self.packages.${system}.testEnv}/home-path/bin";
              }
            ];
            packages = with pkgs; [
              nixd
              nixfmt
            ];
          };
        };
    };
}
