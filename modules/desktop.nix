{ config, pkgs, ... }:

let
  # Create a FHS-like ROCm directory by merging necessary packages
  rocmEnv = pkgs.symlinkJoin {
    name = "rocm-combined";
    paths = with pkgs.rocmPackages; [
      rocminfo
      clr
      rocm-device-libs
    ];
  };
in
{
# --- GRAPHICS (Radeon 890M / Framework 16) ---
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # For Steam/Wine
    
    # OpenCL Support for AMD
    extraPackages = with pkgs; [
      rocmPackages.clr.icd  # OpenCL
    ];
  };

  # --- HIP WORKAROUNDS ---
  # 1. Create a full /opt/rocm structure so HIP can find 'lib' and 'share' (for bitcode)
  systemd.tmpfiles.rules = [
    "L+  /opt/rocm  -  -  -  -  ${rocmEnv}"
  ];

  # 2. Environment Variables for Ryzen AI 300 (gfx1150)
  environment.variables = {
    # Force RDNA 3 compatibility (gfx1100 is the closest stable target for 890M/780M)
    "HSA_OVERRIDE_GFX_VERSION" = "11.0.0";
    
    # Point HIP to the bitcode files within our constructed environment
    # NixOS places these in share/amdgcn/bitcode, but some apps look elsewhere.
    # We point to the symlinkJoin path to ensure stability.
    "HIP_DEVICE_LIB_PATH" = "/opt/rocm/share/amdgcn/bitcode";
  };

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
