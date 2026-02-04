{
  description = "CPSC 121 Lab";
  inputs = { nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"; };
  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      fhs = pkgs.buildFHSEnv {
        name = "cpsc121";
        targetPkgs = pkgs: with pkgs; [ gnumake gcc clang clang-tools cmake git lsb-release python3 glibc gtest gtest.dev ];
        runScript = pkgs.writeScript "init-cpsc121" "exec zsh";
      };
    in { devShells.${system}.default = pkgs.mkShell { packages = [ fhs ]; }; };
}