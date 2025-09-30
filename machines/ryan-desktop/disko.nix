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
        device = "/dev/disk/by-id/nvme-Samsung_SSD_9100_PRO_4TB_S7YANJ0Y514153F";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            # boot = {
            #   size = "1M";
            #   type = "EF02"; # for grub MBR
            # };
            # ESP = {
            #   size = "1G";
            #   type = "EF00";
            #   content = {
            #     type = "filesystem";
            #     format = "vfat";
            #     mountpoint = "/boot";
            #     mountOptions = [ "umask=0077" ];
            #   };
            # };
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
                    # Choose your PCR binding; 7 is a safe default (Secure Boot policy).
                    "tpm2-pcrs=7"
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
