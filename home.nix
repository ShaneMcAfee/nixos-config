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
    ripgrep  # Super fast 'grep' alternative
    fd       # Super fast 'find' alternative

    # 2. Web Development
    nodejs_22
    yarn

    # 3. Cyber Security
    nmap        # Network Scanner
    burpsuite   # Web vulnerability scanner
    ghidra      # Reverse Engineering tool

    # 4. Productivity & General
    obsidian       # Notes
    libreoffice-qt # Office
    zoom-us
    keepassxc      # Passwords
    protonvpn-gui
    fastfetch      # System Info
    vlc            # Media Player
  ];

  # --- PROGRAM CONFIGURATIONS ---
  
  # VS Code (Installing it this way makes it available to you)
  programs.vscode = {
    enable = true;
    package = pkgs.vscode; 
  };

  # Git Configuration (So you don't have to run 'git config --global' commands)
  programs.git = {
    enable = true;
    userName = "Shane McAfee";
    userEmail = "change-this-to-your-email@example.com";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # This version should match your install time (do not change usually)
  home.stateVersion = "24.11";
}
