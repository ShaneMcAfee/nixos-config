{ config, pkgs, ... }:

{
  home.username = "shane";
  home.homeDirectory = "/home/shane";

  # --- USER PACKAGES ---
  home.packages = with pkgs; [
    # 1. Computer Engineering (C++, Python, Debugging)
    python3
    cmake
    gdb
    ripgrep  # 'grep' alternative
    fd       # 'find' alternative
    clang
    clang-tools

    # 2. Web Development
    nodejs_22
    yarn

    # 3. Cyber Security
    nmap        # Network Scanner
    burpsuite   # Web vulnerability scanner
    ghidra      # Reverse Engineering tool

    # 4. Productivity & General
    obsidian       # Notes
    libreoffice-qt 
    zoom-us
    keepassxc
    protonvpn-gui
    fastfetch      # System Info
    vlc
    discord
    nix-output-monitor
    btop
  ];

  # --- PROGRAM CONFIGURATIONS ---
  
  # VS Code (Installing it this way makes it available to you)
  programs.vscode = {
    enable = true;
    package = pkgs.vscode; 
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true; # Hooks into your shell
    nix-direnv.enable = true;    # Caches the environment so it's fast
  };

  # --- SHELL CONFIGURATION ---
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      # 1. 'rebuild' now uses 'nom' for pretty output and clear errors
      rebuild = "sudo -v && sudo nixos-rebuild switch --flake ~/nixos-config --log-format internal-json -v |& nom --json";

      # 2. 'upgrade' updates flake.lock, then rebuilds
      upgrade = "nix flake update --flake ~/nixos-config && sudo nixos-rebuild switch --flake ~/nixos-config --log-format internal-json -v |& nom --json";

      # 3. 'gc' logs to a file instead of spamming the terminal
      gc = "sudo nix-collect-garbage --delete-older-than 7d > ~/nixos-config/logs/gc-$(date +%Y-%m-%d).log 2>&1 && echo 'Garbage collected! Log saved to ~/nixos-config/logs/'";
    };

  # Custom Functions
    initContent = ''
      # Command: sys-save "Commit Message"
      function sys-save() {
        if [ -z "$1" ]; then
          echo "❌ Error: You must provide a commit message."
          echo "Usage: sys-save \"Your message here\""
          return 1
        fi

        # 1. Ask for password UPFRONT so the prompt isn't hidden
        sudo -v
        if [ $? -ne 0 ]; then
            echo "❌ Sudo authentication failed. Aborting."
            return 1
        fi

        echo "📦 Staging files..."
        git -C ~/nixos-config add .

        echo "🛠️  Rebuilding system..."
        # Rebuild using 'nom'. 
        if sudo nixos-rebuild switch --flake ~/nixos-config --log-format internal-json -v |& nom --json; then
            echo "✅ Build Successful!"

            echo "💾 Committing changes..."
            git -C ~/nixos-config commit -m "$1"

            echo "🚀 Pushing to GitHub..."
            git -C ~/nixos-config push

            echo "🎉 Done! System updated and backed up."
        else
            echo "💥 Build Failed! Fix the errors above. Nothing was committed."
            return 1
        fi
      }
    '';
  };

  # --- STARSHIP CONFIGURATION ---
  programs.starship = {
    enable = true;
    # Custom settings can go here, but default is excellent
  };

  # Git Configuration (So you don't have to run 'git config --global' commands)
programs.git = {
    enable = true;
    
    # --- GLOBAL IDENTITY (New Structure) ---
    settings = {
      user = {
        name = "Shane McAfee";
        email = "shanemcafee10@gmail.com";
      };
    };

    # --- SCHOOL OVERRIDE ---
    includes = [
      {
        condition = "gitdir:~/school/";
        contents = {
          user = {
            email = "shanemcafee@csu.fullerton.edu";
          };
        };
      }
    ];
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # This version should match your install time (do not change usually)
  home.stateVersion = "24.11";
}
