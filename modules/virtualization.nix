{ config, pkgs, ... }:

{
  # --- KVM & VIRTUALIZATION ---
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
      # ovmf is enabled by default in Unstable
    };
  };

  # GUI Manager
  programs.virt-manager.enable = true;

  # Tools
  environment.systemPackages = with pkgs; [
    virt-viewer
    spice-gtk
    spice-protocol
    virtio-win # <--- New package name
    # win-spice <--- Removed to prevent further rename errors
  ];
}
