{ config, pkgs, inputs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
      ./modules/desktop.nix
      ./modules/core.nix
      ./modules/virtualization.nix  # <--- Added
    ];


  # --- FRAMEWORK 16 SPECIFICS ---
  # Kernel Params for Ryzen AI 300
  boot.kernelParams = [ "amdgpu.mes=0" "amdgpu.abmlevel=0" ];
  
  # Fix "Backpack Wake"
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", DRIVERS=="usb", ATTRS{idVendor}=="32ac", ATTRS{idProduct}=="0012", ATTR{power/wakeup}="disabled"
    SUBSYSTEM=="usb", DRIVERS=="usb", ATTRS{idVendor}=="32ac", ATTRS{idProduct}=="0014", ATTR{power/wakeup}="disabled"
    SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", MODE="0660", GROUP="adbusers", TAG+="uaccess"
  '';

  # Firmware, Fingerprint, & Power
  services.fwupd.enable = true;
  services.fprintd.enable = true;
  services.power-profiles-daemon.enable = true;

  # Solaar for Logitech devices
  services.solaar = {
    enable = true;
    window = "hide"; # Start in tray
    batteryIcons = "regular";
  };

  # --- USER CONFIGURATION ---
  users.users.shane = {
    isNormalUser = true;
    description = "Shane McAfee";
    extraGroups = [ "networkmanager" "wheel" "wireshark" "libvirtd" "adbusers" "plugdev" ]; 
    shell = pkgs.zsh;
    packages = with pkgs; [ kdePackages.kate ];
  };

  # --- SPECIFIC PROGRAMS ---
  programs.firefox.enable = true;
  programs.wireshark.enable = true;

  # --- HOME MANAGER ---
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users.shane = import ./home.nix;
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  system.stateVersion = "25.11";
}
