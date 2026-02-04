{ config, pkgs, ... }:

{
# --- GRAPHICS (Radeon 890M / Framework 16) ---
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # For Steam/Wine
    
    # OpenCL Support for AMD
    extraPackages = with pkgs; [
      rocmPackages.clr.icd  # OpenCL
      rocmPackages.clr      # Common Language Runtime
    ];
  };

# Workaround for software with hard-coded HIP paths (per NixOS Wiki)
  systemd.tmpfiles.rules = [
    "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
  ];
  # --- DESKTOP ENVIRONMENT (KDE Plasma 6) ---
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;

  # --- LOGITECH DEVICES ---
  services.solaar = {
    enable = true;
    window = "hide";
    batteryIcons = "regular";
  };

  # Keymap
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # --- PRINTING ---
  services.printing.enable = true;

  # --- BLUETOOTH ---
  hardware.bluetooth.enable = true;

  # --- AUDIO (Pipewire) ---
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}
