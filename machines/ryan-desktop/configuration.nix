{ config, pkgs, lib, inputs, hostname, username, ... }:
let
  inherit (inputs) self;
  my1p = pkgs._1password-gui.overrideAttrs (old: {
    # see https://www.1password.community/discussions/1password/1password-window-blank-on-gnome-47-wayland--fedora-41/153548/replies/153967
    # Also, this patches things to actually use ozone
    preFixup = old.preFixup + ''\
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
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      inputs.xremap-flake.nixosModules.default
      inputs.niri-flake.nixosModules.niri
    ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true; # true in asahi
  boot.loader.efi.canTouchEfiVariables = false; # Fale in asahi

  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 48 * 1024; # plus 16 from partition.
  }];

  networking.hostName = hostname; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager = {
    enable = true;
    wifi.backend = "iwd";
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
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    57621 # spotify https://nixos.wiki/wiki/Spotify
    8188 # comfyui
  ];
  networking.firewall.allowedUDPPorts = [
    5353 # spotify and google cast https://nixos.wiki/wiki/Spotify
  ];

  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Remote connectivity
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.PermitRootLogin = "no";
  };
  programs.ssh.startAgent = true;
  services.mullvad-vpn.enable = false;
  services.tailscale.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

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
  services.displayManager = {
    # KDE login/display manager
    sddm = {
      enable = true;
      wayland.enable = true;
    };
    # this is the desktop manager that gets launched
    defaultSession = "niri";
  };
  # KDE plasma window manager
  services.desktopManager = {
    plasma6 = {
      enable = true;
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

  # Enable OpenGL
  hardware.graphics = {
    enable = true;
  };
  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of
    # supported GPUs is at:
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    # Only available from driver 515.43.04+
    open = true;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.production;
  };

  programs.adb.enable = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  services.pipewire = {
    enable = true; # redundant, here for clarity
    pulse.enable = true;
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
  users.users.ryan = {
    isNormalUser = true;
    extraGroups = [
      "adbusers"
      "dialout"
      "docker"
      "networkmanager"
      "plugdev"
      "podman"
      "wheel"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL0Oa3J6JPCPyJL20pHC6kTJ5XnZb7W8nNL3xw+cwixU ryan@ryan-asahi"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBrQiHPGP0KIT1dBEKOkZ9j7xkAqPDii1xWgCnQZHyvC ryan@juicessh"
    ];
    packages = with pkgs; [
      legcord
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
    _1password.enable = true;
    _1password-gui = {
      package = my1p;
      enable = true;
      # cli needs this
      polkitPolicyOwners = [ "${username}" ];
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    alsa-utils # aplay, arecord, etc
    brightnessctl # control screen brightness
    curl
    ffmpeg-full
    git
    glxinfo
    inhibitor # disable built-in keeb and other input devices
    libnotify # notify-send
    neovim
    pkgs.xwayland-satellite-stable
    qpwgraph # control pipewire nodes using a GUI
    ripgrep
    swaylock-effects
    swww
    usbutils # lsusb
    v4l-utils # v4l2-ctl
    vim
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

  services.monado = {
    enable = true;
    # defaultRuntime = true; # Register as default OpenXR runtime
  };
  systemd.user.services.monado.environment = {
    # STEAMVR_LH_ENABLE = "1";
    XRT_COMPOSITOR_COMPUTE = "1";
  };
  services.wivrn = {
    enable = true;
    defaultRuntime = true; # Register as default OpenXR runtime
    openFirewall = true;
    # Run WiVRn as a systemd service on startup
    autoStart = true;
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
    gamescopeSession.enable = true;
  };
  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  programs.droidcam.enable = true;
  # programs.obs-studio = {
  #   enable = true;
  #   enableVirtualCamera = true;
  #   plugins = [
  #     pkgs.obs-studio-plugins.droidcam-obs
  #     # pkgs.obs-studio-plugins.wlrobs
  #   ];
  # };

  hardware.nvidia-container-toolkit = {
    enable = true;
    # suppressNvidiaDriverAssertion = true;
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
