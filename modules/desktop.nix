{ config, pkgs, ... }:

{
  # --- GRAPHICS (Radeon 890M) ---
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # For Steam/Wine
  };

  # --- DESKTOP ENVIRONMENT (KDE Plasma 6) ---
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;

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
