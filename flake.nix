{
  description = "A Nix flake for my ripvcs";

  nixConfig = {
    substituters = [
      "https://cache.nixos.org"
      "https://cache.flox.dev"
      "https://nxmatic.cachix.org"
    ];

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="
      "nxmatic.cachix.org-1:huMghYiwDpPa1PMXHXK4G1Dp4QOZjgsNqxcjf/AjuJ0="
    ];
  };

  inputs = {
    nxmatic-flake-commons.url = "github:nxmatic/nix-flake-commons/develop";

    flake-compat.follows = "nxmatic-flake-commons/flake-compat";
    flake-utils.follows = "nxmatic-flake-commons/flake-utils";

    nix.follows = "nxmatic-flake-commons/nix";
    nixpkgs.follows = "nxmatic-flake-commons/nixpkgs";
  };


  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        sources = import .nvfetcher/generated.nix {
          inherit (pkgs) fetchgit fetchurl fetchFromGitHub dockerTools;
        };
      in {
        # Define your package
        packages.default = pkgs.buildGoModule {
          pname = "ripvcs";

          version = sources.ripvcs.version;
          src = sources.ripvcs.src;

          # Initiate vendorHash using nix develop and running nix hash vendor in the source module
          vendorHash = "sha256-TGPHmij30bdQJ7VX1YF14VQnXTm964gGTAOqBuVwrVs=";

          meta = {
            homepage = "https://github.com/ErickKramer/ripvcs";
            description = "ripvcs (rv) is a command-line tool written in Go, providing an efficient alternative to vcstool for managing multiple repository workspaces.";
            license = [ pkgs.lib.licenses.mit ];
            maintainers = [ "erickkramer@gmail.com" ];
            mainProgram = "rv";
          };

          nativeBuildInputs = [ pkgs.git ];  # Add git to nativeBuildInputs
          checkPhase = "true";  # No-op command
        };

        # Define a development shell
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [ git go gopls nvfetcher nix-prefetch ];
        };
      }
    );
}

