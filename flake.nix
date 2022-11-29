{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "aarch64-darwin"  "x86_64-linux" ] (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShell = with pkgs; mkShell {
          packages = [
            fswatch # To run the frontend while watching for changes
            nim
            nimlsp
          ];
        };
      }
    );
}
