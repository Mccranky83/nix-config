{
  self,
  nixpkgs,
  pre-commit-hooks,
  ...
}@inputs:
let
  inherit (inputs.nixpkgs) lib;
  mylib = import ../lib { inherit lib; };
  myvars = import ../vars { inherit lib; };

  # Add my custom lib, vars, nixpkgs instance, and all the inputs to specialArgs,
  # so that I can use them in all my nixos/home-manager modules.
  genSpecialArgs =
    system:
    let
      pkgs-stable = import inputs.nixpkgs-stable {
        inherit system;
        config.allowUnfree = true;
      };
    in
    inputs
    // {
      inherit mylib myvars pkgs-stable;

      pkgs-2505 = import inputs.nixpkgs-2505 {
        inherit system;
        config.allowUnfree = true;
      };
      pkgs-master = import inputs.nixpkgs-master {
        inherit system;
        config.allowUnfree = true;
      };
      pkgs-blender = import inputs.nixpkgs-blender {
        inherit system;
        config.allowUnfree = true;
      };

      pkgs-x64 = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
        overlays = import ../overlays args;
      };
    };

  # This is the args for all the haumea modules in this folder.
  args = {
    inherit
      inputs
      lib
      mylib
      myvars
      genSpecialArgs
      ;
  };

  # modules for each supported system
  nixosSystems = {
    aarch64-linux = import ./aarch64-linux (args // { system = "aarch64-linux"; });
  };
  allSystemNames = builtins.attrNames nixosSystems;
  nixosSystemValues = builtins.attrValues nixosSystems;

  # Helper function to generate a set of attributes for each system
  forAllSystems = func: (nixpkgs.lib.genAttrs allSystemNames func);
in
{
  # Add attribute sets into outputs, for debugging
  debugAttrs = {
    inherit
      nixosSystems
      allSystemNames
      ;
  };

  # NixOS Hosts
  nixosConfigurations = lib.attrsets.mergeAttrsList (
    map (it: it.nixosConfigurations or { }) nixosSystemValues
  );

  # Packages
  packages = forAllSystems (system: nixosSystems.${system}.packages or { });

  # Eval Tests for all NixOS systems.
  evalTests = lib.lists.all (it: it.evalTests == { }) nixosSystemValues;

  checks = forAllSystems (system: {
    # eval-tests per system. `nix flake check` requires every check to be a
    # derivation, so wrap the boolean result in one instead of returning a bool.
    eval-tests =
      let
        pkgs = nixpkgs.legacyPackages.${system};
        results = nixosSystems.${system}.evalTests;
      in
      pkgs.runCommand "eval-tests" { } (
        if results == { } then
          "touch $out"
        else
          "echo 'eval tests failed: evalTests is not empty' >&2; exit 1"
      );

    pre-commit-check = pre-commit-hooks.lib.${system}.run {
      src = mylib.relativeToRoot ".";
      hooks = {
        nixfmt = {
          enable = true;
          settings.width = 100;
        };
        # Source code spell checker
        typos = {
          enable = true;
          settings = {
            write = true; # Automatically fix typos
            configPath = ".typos.toml"; # relative to the flake root
            exclude = "rime-data/";
          };
        };
        prettier = {
          enable = true;
          settings = {
            write = true; # Automatically format files
            configPath = ".prettierrc.yaml"; # relative to the flake root
          };
        };
        # deadnix.enable = true; # detect unused variable bindings in `*.nix`
        # statix.enable = true; # lints and suggestions for Nix code(auto suggestions)
      };
    };
  });

  # Development Shells
  devShells = forAllSystems (
    system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      default = pkgs.mkShell {
        packages = with pkgs; [
          # fix https://discourse.nixos.org/t/non-interactive-bash-errors-from-flake-nix-mkshell/33310
          bashInteractive
          # fix `cc` replaced by clang, which causes nvim-treesitter compilation error
          gcc
          # Nix-related
          nixfmt
          deadnix
          statix
          # spell checker
          typos
          # code formatter
          prettier
        ];
        name = "dots";
        inherit (self.checks.${system}.pre-commit-check) shellHook;
      };
    }
  );

  # Format the nix code in this flake
  formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);
}
