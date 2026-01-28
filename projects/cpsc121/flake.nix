{
  description = "CPSC 121 - Ubuntu Compatibility Bubble";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      
      # The Ubuntu Simulation Bubble
      fhs = pkgs.buildFHSEnv {
        name = "cpsc121";
        targetPkgs = pkgs: with pkgs; [
          # --- Toolchain ---
          gnumake
          gcc
          clang
          clang-tools
          cmake
          git
          
          # --- Dependencies ---
          lsb-release
          python3
          
          # --- Libraries ---
          glibc
          
          # FORCE headers to be available
          gtest
          gtest.dev 
        ];
        
        # Explicitly link headers if they aren't found automatically
        # and create the Python aliases your script demands
        runScript = pkgs.writeScript "init-cpsc121" ''
          # 1. Create Python Aliases (Fixes 'no python3.7/3.8')
          ln -fs $(which python3) /tmp/python3.7
          ln -fs $(which python3) /tmp/python3.8
          export PATH=$PATH:/tmp
          
          # 2. Set CPATH so Clang finds gmock/gtest even if /usr/include is wonky
          export CPATH=/usr/include:$CPATH
          
          # 3. Drop into the shell
          exec zsh
        '';
      };
    in
    {
      # The Outer Shell
      devShells.${system}.default = pkgs.mkShell {
        packages = [ fhs ];
        shellHook = ''
          echo "🎓 CPSC 121 Environment Loaded."
          echo "Run 'cpsc121' to enter the lab simulation."
        '';
      };
    };
}
