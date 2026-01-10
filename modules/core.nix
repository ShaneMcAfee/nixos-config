{ config, pkgs, ... }:

{
  # --- BOOTLOADER ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # --- NETWORKING ---
  networking.hostName = "framework16";
  networking.networkmanager.enable = true;

  # --- TIME & LOCALE ---
  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # --- NIX SETTINGS ---
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # --- SYSTEM PACKAGES ---
  # Basic tools available to root and all users
  environment.systemPackages = with pkgs; [
    vim
    wget
    bluez
    bluez-tools
    git
    gcc
    gnumake
  ];
  
  # --- SHELL ---
  programs.zsh.enable = true;
}
