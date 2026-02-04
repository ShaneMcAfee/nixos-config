{ config, pkgs, ... }:

{
  home.username = "shane";
  home.homeDirectory = "/home/shane";

  # --- USER PACKAGES ---
  home.packages = with pkgs; [
    #  Computer Engineering (C++, Python, Debugging)
    python3
    cmake
    gdb
    ripgrep  # 'grep' alternative
    fd       # 'find' alternative
    clang
    clang-tools
    tailscale
    tailscalesd
    gtest

    #  Web Development
    nodejs_22
    yarn

    #  Cyber Security
    nmap        # Network Scanner
    burpsuite   # Web vulnerability scanner
    ghidra      # Reverse Engineering tool
    hashcat     # Password cracker
    hashcat-utils

    #  Productivity & General
    ungoogled-chromium
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
    tree
  ];

  # --- PROGRAM CONFIGURATIONS ---
  
  # VS Code (Installing it this way makes it available to you)
# --- PROGRAM CONFIGURATIONS ---
  
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    
    # New Home Manager Structure: "profiles.default"
    profiles.default = {
      
      # Extensions via Nix
      extensions = with pkgs.vscode-extensions; [
        ms-vscode.cpptools          # C++ Engine
        ms-vscode.makefile-tools    # Makefile Support
        # ms-vscode.vs-keybindings  # (Removed due to build error previously)
      ];

      # VS Code Settings
      userSettings = {
        # Visuals
        "workbench.colorTheme" = "Visual Studio Dark"; 
        "workbench.iconTheme" = "vs-minimal";
        "editor.fontFamily" = "'Consolas', 'Droid Sans Mono', 'monospace'";
        
        # C++ & Google Style
        "C_Cpp.default.compilerPath" = "clang++";
        "C_Cpp.default.cppStandard" = "c++20";
        "C_Cpp.intelliSenseEngine" = "default";
        "C_Cpp.clang_format_style" = "Google";
        "editor.formatOnSave" = true;
        "[cpp]" = {
          "editor.defaultFormatter" = "ms-vscode.cpptools";
        };

        # Makefile
        "makefile.configureOnOpen" = true;
      };
    };
  };

  # --- SHELL CONFIGURATION ---
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      # --- NAVIGATION & EDITING ---
      cdnix = "cd ~/nixos-config";
      
      # Quick Edits (Terminal)
      conf-sys  = "nano ~/nixos-config/hosts/framework16/configuration.nix";
      conf-home = "nano ~/nixos-config/users/shane/home.nix";
      conf-flake = "nano ~/nixos-config/flake.nix";
      
      # Full IDE (VS Code)
      code-nix = "code ~/nixos-config";

      # --- SYSTEM MAINTENANCE ---
      rebuild = "sudo -v && sudo nixos-rebuild switch --flake ~/nixos-config --log-format internal-json -v |& nom --json";
      upgrade = "nix flake update --flake ~/nixos-config && sudo nixos-rebuild switch --flake ~/nixos-config --log-format internal-json -v |& nom --json";
      rollback = "sudo nixos-rebuild switch --rollback";
      undo-edits = "git -C ~/nixos-config reset --hard";
      gc = "sudo nix-collect-garbage --delete-older-than 7d > ~/nixos-config/logs/gc-$(date +%Y-%m-%d).log 2>&1 && echo 'Garbage collected! Log saved to ~/nixos-config/logs/'";
      # Clears screen, lists tree, and dumps core config files with headers
      dump-config = "clear && echo '--- FILE TREE ---' && ls -R ~/nixos-config && echo -e '\\n--- FLAKE.NIX ---' && cat ~/nixos-config/flake.nix && echo -e '\\n--- CONFIGURATION.NIX ---' && cat ~/nixos-config/hosts/framework16/configuration.nix && echo -e '\\n--- HOME.NIX ---' && cat ~/nixos-config/users/shane/home.nix";
      
      # --- HELP MENU ---
      help-me = "echo -e '\\n🛠️  NIXOS COMMANDS:\\n  cdnix      : Go to config folder\\n  conf-sys   : Edit System Config (nano)\\n  conf-home  : Edit Home Config (nano)\\n  code-nix   : Edit All Configs (VS Code)\\n\\n  rebuild    : Apply changes (Quick)\\n  upgrade    : Update packages (Slow)\\n  sys-save   : Git Save & Apply\\n  rollback   : Revert System Binaries\\n'";
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
    
    # --- GLOBAL IDENTITY (Personal) ---
    settings = {
      user = {
        name = "Shane McAfee";
        email = "shanemcafee10@gmail.com";
      };
    };

    # --- SCHOOL OVERRIDE ---
    includes = [
      {
        # Use the ABSOLUTE path to be 100% sure
        condition = "gitdir:/home/shane/school/";
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
