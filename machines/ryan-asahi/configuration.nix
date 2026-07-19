{
  pkgs,
  lib,
  inputs,
  config,
  hostname,
  username,
  isWork,
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

  # pkgsX86 = import pkgs.path {
  #   system = "x86_64-linux";
  #   config = config.nixpkgs.config;
  # };
  # x86DynamicLinker = pkgsX86.stdenv.cc.bintools.dynamicLinker;
  # x86LdsoDir = pkgsX86.stdenv.hostPlatform.libDir;
  # x86LdsoName = builtins.baseNameOf x86DynamicLinker;
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    inputs.nixos-apple-silicon.nixosModules.apple-silicon-support
    inputs.xremap-flake.nixosModules.default
    inputs.niri-flake.nixosModules.niri
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
    enable = true;
    # Ensures reproducibility of firmware
    peripheralFirmwareDirectory = ./firmware; # vendored instead of /boot/asahi
    extractPeripheralFirmware = true; # redundant, this is the default
  };

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

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    57621 # spotify https://nixos.wiki/wiki/Spotify
    22000 # syncthing
  ];
  networking.firewall.allowedUDPPorts = [
    5353 # mDNS
    22000 # syncthing
  ];
  # networking.firewall.interfaces."nxpeth0".allowedUDPPorts = [
  #   53 # DNS for downstream client
  #   67 # DHCP server on host
  # ];

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Set your time zone.
  time.timeZone = null; # imperatively set with timedatectl

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
  services.gnome.gcr-ssh-agent.enable = false;
  programs.seahorse.enable = true; # gnome keyring UI
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
    asahi-bless
    asahi-fwextract
    awww
    brightnessctl # control screen brightness
    chromium
    curl
    ffmpeg-full
    git
    libnotify # notify-send
    libsecret # needed for gnome-keyring
    mesa-demos
    neovim
    pkgs.xwayland-satellite-stable
    ripgrep
    usbutils # lsusb
    v4l-utils # v4l2-ctl
    vim
    vulkan-tools
    wezterm
    wget
  ];

  services.monado = {
    enable = true;
    # defaultRuntime = true; # Register as default OpenXR runtime
  };
  systemd.user.services.monado.environment = {
    IPC_EXIT_ON_DISCONNECT = "1"; # stop monado when all xr apps close
    # STEAMVR_LH_ENABLE = "1";
    XRT_COMPOSITOR_COMPUTE = "1";
  };
  services.sunshine = {
    enable = true;
    autoStart = false;
    capSysAdmin = true;
    openFirewall = true;
  };

  # For yubikey smart card
  services.pcscd.enable = true;

  services.ollama = {
    enable = true;
    package = pkgs.unstable.ollama-vulkan;
  };

  thebutlah = {
    vpn.enable = true;
    inhibitor = {
      enable = true;
      builtinName = "Apple MTP keyboard";
    };
    displayManager = {
      enable = true;
      windowManager = "niri";
    };
    streaming.enable = true;
  };
  services.zerotierone.enable = true;

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
