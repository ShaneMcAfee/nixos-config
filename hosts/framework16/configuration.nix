{ config, pkgs, inputs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../../modules/desktop.nix
      ../../modules/core.nix
      ../../modules/virtualization.nix
    ];

  # --- FRAMEWORK 16 SPECIFICS ---
  # Kernel Params for Ryzen AI 300
  # Added amdgpu.sg_display=0 to fix white/backlight-only screen on wake
  boot.kernelParams = [ "amdgpu.mes=0" "amdgpu.abmlevel=0" "amdgpu.sg_display=0" ];

  # --- POWER & HIBERNATION ---
  # Fix for "Black Screen" crashes on low battery/hibernate (32GB Swap)
  swapDevices = [ { device = "/swapfile"; size = 32 * 1024; } ];

  # Ensure we suspend correctly before hibernating
  systemd.sleep.extraConfig = ''
    AllowHibernation=yes
    AllowHybridSleep=yes
    SuspendState=mem
  '';

  # --- INPUT WAKE FIXES ---
  # Prevent Framework Input Modules (Keyboards/Pads) from waking the laptop
  # Vendor 32ac = Framework. Disabling wake for all 32ac USB devices.
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTRS{idVendor}=="32ac", ATTR{power/wakeup}="disabled"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="32ac", ATTR{driver/usb/power/wakeup}="disabled"
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
    extraGroups = [ "networkmanager" "wheel" "wireshark" "libvirtd" ];
    shell = pkgs.zsh;
    packages = with pkgs; [ kdePackages.kate ];
  };

  # --- SPECIFIC PROGRAMS ---
  programs.firefox.enable = true;
  programs.wireshark.enable = true;

  # --- HOME MANAGER ---
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users.shane = import ../../users/shane/home.nix;
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  system.stateVersion = "25.11";
}
