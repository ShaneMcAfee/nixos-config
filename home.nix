{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should manage.
  home.username = "shane";
  home.homeDirectory = "/home/shane";

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    fastfetch
    ripgrep
    # You can move packages from configuration.nix here if they are just for you
  ];

  # Basic Git configuration (Example of Home Manager managing dotfiles)
  programs.git = {
    enable = true;
    userName = "ShaneMcAfee";
    userEmail = "shanemcafee10@gmail.com";
  };

  # Bash configuration
  programs.bash = {
    enable = true;
    enableCompletion = true;
    # TODO: Add your custom bash aliases here
    shellAliases = {
      ll = "ls -l";
      update = "sudo nixos-rebuild switch";
    };
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.11"; # Keep consistent with your install time
  
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
