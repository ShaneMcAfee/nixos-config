{
  description = "The Golden Shell - Homelab Staging Environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    nixosConfigurations.golden-shell = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ({ pkgs, modulesPath, ... }: {
          imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

          # --- VM HARDWARE & SPECS ---
          boot.loader.grub.device = "/dev/vda";
          fileSystems."/" = { device = "/dev/vda1"; fsType = "ext4"; };
          
          virtualisation.vmVariant = {
            virtualisation = {
              memorySize = 4096;
              cores = 4;
              graphics = true;
              diskSize = 20480;
            };
            virtualisation.forwardPorts = [
              { from = "host"; host.port = 2222; guest.port = 22; }
            ];
          };

          # --- SERVER CONFIG ---
          networking.hostName = "golden-shell";
          networking.firewall.enable = false;

          virtualisation.docker.enable = true;
          virtualisation.docker.storageDriver = "overlay2";
          users.users.root.extraGroups = [ "docker" ];

          services.resolved.enable = false; 
          services.spice-vdagentd.enable = true;
          
          services.openssh.enable = true;
          services.openssh.settings.PermitRootLogin = "prohibit-password"; 
          users.users.root.openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMCyUHU8W6yrfm6snrbbdQDm3a3utciWyIeOiamBbaR6 shanemcafee10@gmail.com" ];

          systemd.tmpfiles.rules = [
            "d /tank/data 0777 root root - -"
            "d /mnt/media 0777 root root - -"
            "d /var/lib/docker-data 0777 root root - -"
          ];

          environment.systemPackages = with pkgs; [ git vim docker-compose htop curl wget ];
          services.getty.autologinUser = "root";
          system.stateVersion = "25.11";

          # --- IMPROVED INJECTION (Map Entire Folder) ---
          environment.etc."homelab-source".source = ./services;

          system.activationScripts.setupHomelab = {
            text = ''
              echo "--- SETTING UP HOMELAB ---"
              mkdir -p /root/homelab
              
              if [ -d /etc/homelab-source ]; then
                # -L: Dereference (Copy actual files, not links)
                cp -Lrf /etc/homelab-source/. /root/homelab/
                chmod -R 755 /root/homelab
                echo "Success: Injected services folder."
              else
                echo "ERROR: Source folder not found!"
              fi
            '';
            deps = [];
          };
        })
      ];
    };
  };
}
