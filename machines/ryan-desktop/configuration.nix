{
  config,
  pkgs,
  lib,
  inputs,
  hostname,
  username,
  ...
}:
let
  ethernetAdapter = "enp6s0";
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
  # linuxPackages = (pkgs.unstable.linuxPackagesFor pkgs.linuxPackages.kernel);
  linuxPackages = pkgs.linuxPackages;
  secureBoot = true;
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    inputs.niri-flake.nixosModules.niri
    inputs.disko.nixosModules.disko
    ./disko.nix
    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  # https://github.com/nix-community/lanzaboote/blob/747b7912f49e2885090c83364d88cf853a020ac1/docs/QUICK_START.md
  # NOTE: Lanzaboote currently replaces the systemd-boot module.
  # This setting is usually set to true in configuration.nix
  # generated at installation time. So we force it to false
  # for now.
  boot.loader.systemd-boot.enable = !secureBoot;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.lanzaboote = {
    enable = secureBoot;
    pkiBundle = "/var/lib/sbctl";
  };
  boot.kernelParams = [
    "usbcore.autosuspend=-1" # https://www.kernel.org/doc/html/v4.16/driver-api/usb/power-management.html#changing-the-default-idle-delay-time
  ];

  # we want the latest nvidia drivers, which will come with the latest kernel.
  boot.kernelPackages = linuxPackages;

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 48 * 1024; # plus 16 from partition.
    }
  ];

  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager = {
    enable = true;
    wifi.backend = "iwd";
    settings.connection.mdns = 2;
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
  networking.interfaces."${ethernetAdapter}" = {
    wakeOnLan.enable = true;
  };
  services.resolved = {
    enable = true;
    # set to "false" if giving you trouble
    settings.Resolve = {
      DNSOverTLS = "opportunistic";
      MulticastDNS = true;
    };
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    57621 # spotify https://nixos.wiki/wiki/Spotify
    8188 # comfyui
    22000 # syncthing
  ];
  networking.firewall.allowedUDPPorts = [
    5353 # mDNS
    22000 # syncthing
  ];

  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Set your time zone.
  time.timeZone = "America/New_York";

  # We don't enable x11
  services.xserver.enable = false;
  programs.seahorse.enable = true; # gnome keyring UI
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
    package = linuxPackages.nvidiaPackages.beta;
  };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  programs = {
    firefox.enable = true;
    chromium.enable = true;
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
    awww
    brightnessctl # control screen brightness
    chromium
    curl
    ffmpeg-full
    git
    libnotify # notify-send
    libsecret # needed for gnome-keyring
    lighthouse-steamvr # control lighthouse power
    mesa-demos # glxinfo, etc
    neovim
    pkgs.xwayland-satellite-stable
    # protonplus # Manage steam proton versions
    ripgrep
    sbctl # lanzaboote
    usbutils # lsusb
    v4l-utils # v4l2-ctl
    vim
    vulkan-tools
    wezterm
    wget

    wayvr
    (heroic.override {
      extraPkgs = pkgs: [
        pkgs.gamescope
      ];
    })
    xrizer
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
    gamescopeSession.enable = true;
    extraCompatPackages = with pkgs; [
      proton-rtsp-bin # nixpkgs-xr has it
    ];
    package = pkgs.steam.override {
      extraProfile = ''
        # Fixes timezones on VRChat
        unset TZ
        # Allows Monado to be used
        export PRESSURE_VESSEL_IMPORT_OPENXR_1_RUNTIMES=1
      '';
    };
    fontPackages = with pkgs; [ source-han-sans ]; # fixes broken popups
  };
  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  thebutlah = {
    monado.enable = true;
    selfhosting.enable = true;
    ssh.enable = true;
    vpn.enable = true;
    streaming.enable = true;
  };

  services.ollama = {
    enable = true;
    package = pkgs.unstable.ollama-cuda;
    host = "100.94.243.29";
  };

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
