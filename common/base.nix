# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{

  # Virt Manager
  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true; 

  # Docker
  virtualisation.docker.enable = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;


  environment.variables = {
    NIXPKGS_ALLOW_UNFREE = 1;
  };

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    layout = "fr";
  };

  # PCSCd for Yubikey PIV
  services.pcscd.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Cosmic
  services.desktopManager.cosmic.enable = true;
  hardware.opengl.enable = true;

  
  # Disable Wayland compositors to force Xorg
  programs.hyprland.enable = false;
  programs.sway.enable = false;

  services.udev.packages = with pkgs; [ gnome-settings-daemon ];
 
  services.gnome.games.enable = false;
  services.gnome.core-developer-tools.enable = false;
  environment.gnome.excludePackages = with pkgs; [
    gnome-photos
    gnome-tour
    gnome-music
    gnome-calendar
    gnome-maps
#    gnome.gedit
    epiphany
    geary
    evince
    totem
    cheese
    gnome-weather
    gnome-contacts
    gnome-text-editor
  ];

  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "fr";
    xkb.variant = "oss_latin9";
  };

  # Configure console keymap
  console.keyMap = "fr";

  # Enable CUPS to print documents.
  services.printing = { enable = true; drivers = [ pkgs.epson-escpr ]; };

  services.avahi = {
    enable = true;
    openFirewall = true;
  };

  # Bluetooth enable
  hardware.bluetooth.enable = true; 
  services.blueman.enable = true;

  # Enable sound with pipewire.
  #sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

    wireplumber.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mickael = {
    isNormalUser = true;
    description = "mickael";
    initialPassword = "mickael";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "docker" "dialout" ];
    packages = with pkgs; [
      #firefox-wayland
    ];
  };



  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Use non NixOS binaries
  programs.nix-ld.enable = true;

  # Add here all librairies needed by your binaries to run with nix ld
  programs.nix-ld.libraries = with pkgs; [];


  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    hyprland
    wofi
    kitty
    waybar
    coreutils
    util-linux
    xdg-utils

    xwayland

    vim
    neovim
    tailscale
    terminator
    adwaita-icon-theme
    gnomeExtensions.appindicator
    gnomeExtensions.printers
    gnome-settings-daemon
    gnomeExtensions.dashbar
    mutter
    gnomeExtensions.dash-to-panel
    dconf-editor
    gnomeExtensions.printers
    gnomeExtensions.user-themes
    gnomeExtensions.dash-to-dock
    gnomeExtensions.forge
    avahi

  ];

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono
    nerd-fonts.noto
    nerd-fonts.hack
    nerd-fonts.ubuntu

  ];


  # VDIRSYNCER
  services.vdirsyncer = {
    enable = true;

    # JOBS
    jobs.ovh = {
      enable = true;
      user = "mickael";
      group = "users";

      timerConfig = {
        OnBootSec = "5m";
        OnUnitActiveSec = "5m";
      };

      configFile = pkgs.writeText "vdirsyncer-ovh.ini" ''
        [general]
        status_path = "~/.local/share/vdirsyncer/status"

        [storage ovh]
        type = "caldav"
        url = "https://zimbra1.mail.ovh.net/dav/mickael@famille-roger.com/"
        username = "mickael@famille-roger.com"
        password.fetch = ["shell", " cat ~/.config/vdirsync.passwd"]
        item_types = ["VEVENT", "VTODO"]

        [storage local_cal]
        type = "filesystem"
        path = "~/.local/share/vdirsyncer/calendars"
        fileext = ".ics"

        [storage local_tasks]
        type = "filesystem"
        path = "~/.local/share/vdirsyncer/tasks"
        fileext = ".ics"

        [pair calendars]
        a = "local_cal"
        b = "ovh"
        collections = ["Calendar", "Famille"]
        conflict_resolution = "b wins"
        metadata = ["color", "displayname"]

        [pair tasks]
        a = "local_tasks"
        b = "ovh"
        collections = ["Todo"]
        conflict_resolution = "b wins"
        metadata = ["color", "displayname"]
      '';

    };

  };

  services.gnome.gnome-settings-daemon.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:
  services.tailscale.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.settings.X11Forwarding = true;
  services.openssh.settings.X11DisplayOffset = 10;
  services.openssh.settings.X11UseLocalhost = true;

#  system.extraDependencies = with pkgs; [
#    python3Minimal
#    # make-options-doc/default.nix
#    (let
#        self = (pkgs.python3Minimal.override {
#          inherit self;
#          includeSiteCustomize = true;
#        });
#      in self.withPackages (p: [ p.mistune ]))
#  ];

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 8444 4444 3306 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  system.stateVersion = "25.05";

}
