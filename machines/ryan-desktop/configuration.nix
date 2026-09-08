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
    inputs.disko.nixosModules.disko
    ./disko.nix
  ];

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
    dns = "systemd-resolved";
    settings.connection.mdns = 2;
  };
  networking.wireless.iwd = {
    enable = true;
    settings = {
      General = {
        EnableNetworkConfiguration = true;
        Country = "US";
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
    settings.Resolve = {
      DNSOverTLS = "opportunistic";
      MulticastDNS = true;
    };
  };
  networking.interfaces."${ethernetAdapter}" = {
    wakeOnLan.enable = true;
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

  # Set your time zone.
  time.timeZone = "America/New_York";

  # We don't enable x11
  services.xserver.enable = false;
  services.gnome.gnome-keyring.enable = true;
  services.gnome.gcr-ssh-agent.enable = false;
  programs.seahorse.enable = true; # gnome keyring UI
  # https://nixos.wiki/wiki/Wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

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
    # protonplus # Manage steam proton versions
    ripgrep
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
    # selfhosting.enable = true;
    vpn = {
      enable = true;
      # zerotier = true;
    };
    ssh.enable = true;
    displayManager = {
      enable = true;
      windowManager = "niri";
    };
    streaming.enable = true;
    systemdBoot.secureBoot = true;
    nvidia.enable = true;
    comfyui.enable = true;
  };

  services.ollama = {
    enable = true;
    package = pkgs.unstable.ollama-cuda;
    host = "100.94.243.29";
  };
  environment.sessionVariables.OLLAMA_HOST = config.services.ollama.host;

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
