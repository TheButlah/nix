# Comes from
# https://github.com/nix-community/disko-templates/blob/6b12e5fe/single-disk-ext4/disko-config.nix

# USAGE in your configuration.nix.
# Update devices to match your hardware.
# {
#  imports = [ ./disko-config.nix ];
#  disko.devices.disk.main.device = "/dev/nvme0n1";
# }
{
  # ChatGPT: Systemd in initrd is required for TPM/FIDO options in crypttab to work
  boot.initrd.systemd.enable = true;

  disko.devices = {
    disk = {
      linux = {
        device = "/dev/disk/by-id/nvme-WD_BLACK_SN850X_4000GB_25166T803291";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1M";
              type = "EF02"; # for grub MBR
            };
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            rootfs = {
              size = "100%";
              content = {
                type = "luks";
                name = "rootfs";
                # LUKS settings (as defined in configuration.nix in boot.initrd.luks.devices.<name>)
                settings = {
                  allowDiscards = true; # https://wiki.archlinux.org/title/Dm-crypt/Specialties#Discard/TRIM_support_for_solid_state_drives_(SSD)
                  crypttabExtraOpts = [
                    "tpm2-device=auto"
                    # https://uapi-group.org/specifications/specs/linux_tpm_pcr_registry/
                    "tpm2-pcrs=0+1+7"
                  ];
                };
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/";
                  # mountOptions = [ "noatime" ];
                };
              };
            };
            # rootfs = {
            #   size = "100%";
            #   content = {
            #
            #     type = "filesystem";
            #     format = "ext4";
            #     mountpoint = "/";
            #   };
            # };
          };
        };
      };
    };
  };
}
