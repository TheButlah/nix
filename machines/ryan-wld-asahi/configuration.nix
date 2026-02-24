{
  pkgs,
  lib,
  inputs,
  hostname,
  username,
  ...
}:
let
  inherit (inputs) self;
  my1p = pkgs.unstable._1password-gui.overrideAttrs (old: {
    # see https://www.1password.community/discussions/1password/1password-window-blank-on-gnome-47-wayland--fedora-41/153548/replies/153967
    # Also, this patches things to actually use ozone
    preFixup = old.preFixup + ''
      \
            makeShellWrapper $out/share/1password/1password $out/bin/1password \
            "''${gappsWrapperArgs[@]}" \
            --suffix PATH : ${lib.makeBinPath [ pkgs.xdg-utils ]} \
            --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ pkgs.udev ]} \
            --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
            --add-flags "--js-flags=--nodecommit_pooled_pages"
    '';
  });
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    inputs.nixos-apple-silicon.nixosModules.apple-silicon-support
    inputs.xremap-flake.nixosModules.default
    inputs.niri-flake.nixosModules.niri
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings.trusted-users = [
    "root"
    "${username}"
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    systemd-boot = {
      enable = true; # true in asahi
      editor = false;
    };
    timeout = 1;
    efi.canTouchEfiVariables = false; # False in asahi
  };

  hardware.asahi = {
    # Ensures reproducibility of firmware
    peripheralFirmwareDirectory = ./firmware; # vendored instead of /boot/asahi
    extractPeripheralFirmware = true; # redundant, this is the default
  };

  networking.hostName = hostname; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager = {
    enable = true;
    wifi.backend = "iwd";
    settings.wifi.country = "US";
  };
  networking.wireless.iwd = {
    enable = true;
    settings = {
      General = {
        EnableNetworkConfiguration = true;
      };
      IPv6 = {
        Enabled = true;
      };
      Settings = {
        AutoConnect = true;
      };
    };
  };
  services.resolved = {
    enable = true;
    # set to "false" if giving you trouble
    dnsovertls = "opportunistic";
  };
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    57621 # spotify https://nixos.wiki/wiki/Spotify
    22000 # syncthing
  ];
  networking.firewall.allowedUDPPorts = [
    5353 # mDNS
    22000 # syncthing
  ];

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
  # programs.ssh.startAgent = true;
  services.cloudflare-warp.enable = true;
  services.mullvad-vpn.enable = true;
  services.tailscale.enable = true;

  # device trust for IT, to set up enrollment secret, see docs at:
  # https://github.com/kolide/nix-agent
  services.kolide-launcher.enable = true;

  # Set your time zone.
  time.timeZone = null; # imperatively set with timedatectl

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };
  fonts.packages = with pkgs; [
    nerd-fonts.meslo-lg
    nerd-fonts.roboto-mono
  ];

  services.xremap = {
    enable = true;
    userName = "${username}";
    serviceMode = "user";
    withWlroots = true;
    yamlConfig = builtins.readFile ../../xdg/xremap.yaml;
  };

  # We don't enable x11
  services.xserver.enable = false;
  services.gnome.gnome-keyring.enable = true;
  programs.seahorse.enable = true; # gnome keyring UI
  services.greetd = {
    enable = true;
    useTextGreeter = true; # prevent error messages breaking tty
    settings = {
      initial_session = {
        command = "${pkgs.niri}/bin/niri-session";
        user = username;
      };

      # Fallback greeter
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd ${pkgs.niri}/bin/niri-session";
        user = username;
      };
    };
  };
  # tiling window manager
  programs.niri = {
    enable = true;
    package = pkgs.niri-stable;
  };
  niri-flake.cache.enable = false;
  # https://nixos.wiki/wiki/Wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  # TODO: not working rn, I think I need to switch to niri-flake
  # programs.xwayland.enable = true;

  programs.adb.enable = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  services.pipewire = {
    enable = true; # redundant, here for clarity
    pulse.enable = true; # redundant?
    wireplumber = {
      enable = true; # redundant, here for clarify
      configPackages = [
        # (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/10-loopback-pro-audio.conf" (
        #   builtins.readFile ../../xdg/wireplumber-pro-audio.conf
        # ))
      ];
    };
  };
  # redundant, here for clarity. This should be false when using sound servers
  hardware.alsa.enable = false;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."${username}" = {
    isNormalUser = true;
    extraGroups = [
      "adbusers"
      "dialout"
      "docker"
      "libvirt"
      "networkmanager"
      "plugdev"
      "podman"
      "wheel"
      "syncthing"
    ];
    packages = with pkgs; [
      # legcord
      mpv # currently broken in: https://github.com/haasn/libplacebo/issues/333
    ];
  };
  users.defaultUserShell = pkgs.zsh;
  users.groups = {
    plugdev = { };
    dialout = { };
  };

  programs = {
    zsh.enable = true;
    firefox.enable = true;
    chromium.enable = true;
    _1password.enable = true;
    _1password-gui = {
      package = my1p;
      enable = true;
      # cli needs this
      polkitPolicyOwners = [ "${username}" ];
    };
    nix-ld.enable = true;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    alsa-utils # aplay, arecord, etc
    asahi-bless
    asahi-fwextract
    brightnessctl # control screen brightness
    chromium
    curl
    easyeffects
    ffmpeg-full
    git
    inhibitor # disable built-in keeb and other input devices
    libnotify # notify-send
    libsecret # needed for gnome-keyring
    mesa-demos
    neovim
    pavucontrol
    pkgs.xwayland-satellite-stable
    qpwgraph # control pipewire nodes using a GUI
    ripgrep
    sshfs
    swaylock-effects
    swww
    usbutils # lsusb
    v4l-utils # v4l2-ctl
    vim
    virt-manager # for virt-install
    vulkan-tools
    wezterm
    wget
  ];

  # USB stuff
  services.udev = {
    enable = true;
    extraRules = ''
      SUBSYSTEM=="usb", MODE="0660", GROUP="plugdev"
      # SYMLINK also creates a .device with the path of the symlink, i.e. `dev-corne.device`
      ACTION=="add", KERNEL=="event*", SUBSYSTEM=="input", ATTRS{id/vendor}=="1d50", ATTRS{id/product}=="615e", ATTRS{name}=="Corne Keyboard", SYMLINK+="corne", TAG+="systemd", ENV{SYSTEMD_WANTS}="wireless-keyboard.target"
    '';
  };
  services.usbguard = import ../../usbguard.nix;

  # Set up keyboard services
  # This target just helps abstract over the particular name of the device, and its slightly
  # more flexible than using udev directly.
  # See also: https://pychao.com/2021/02/24/difference-between-partof-and-bindsto-in-a-systemd-unit
  systemd.targets."wireless-keyboard" = {
    description = "active when a wireless keyboard is connected";
    after = [ "dev-corne.device" ];
    bindsTo = [ "dev-corne.device" ]; # kills this unit when the device unit is stopped
  };
  systemd.services."builtin-keyboard-disable" = {
    description = "disables built-in keyboard while active";
    after = [ "wireless-keyboard.target" ];
    bindsTo = [ "wireless-keyboard.target" ];
    wantedBy = [ "wireless-keyboard.target" ];
    path = with pkgs; [ inhibitor ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
      ExecStart = "/usr/bin/env inhibitor disable --name \"Apple MTP keyboard\"";
      ExecStop = "/usr/bin/env inhibitor enable --name \"Apple MTP keyboard\"";
    };
  };

  programs.droidcam.enable = true;
  programs.obs-studio = {
    enable = true;
    enableVirtualCamera = true;
    plugins = [
      pkgs.obs-studio-plugins.droidcam-obs
      # pkgs.obs-studio-plugins.wlrobs
    ];
  };

  virtualisation = {
    containers.enable = true;
    oci-containers.backend = "podman";
    podman = {
      enable = true;
      # docker` alias for podman
      dockerCompat = false;
      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
    docker = {
      daemon.settings.features.cdi = true;
      enable = true;
      autoPrune.enable = true;
      enableOnBoot = true;
    };
  };
  virtualisation.libvirtd = {
    enable = true;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?
}
