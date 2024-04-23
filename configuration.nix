# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./pkgs/cybersec.nix
      ./pkgs/kube.nix
      ./pkgs/web.nix
      ./pkgs/tools.nix
      ./pkgs/virtu.nix
      ./pkgs/media.nix
      ./pkgs/cloud.nix
      ./pkgs/dev.nix
      ./pkgs/maker.nix
#      ./pkgs/unstable.nix
      ./home-manager.nix
    ];

  # Add NUR
  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };

  # Virt Manager
  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true; 

  # Docker
  virtualisation.docker.enable = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
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
  services.xserver.enable = true;
  # USe Wayland
  programs.sway.enable = true;
  xdg.portal.wlr.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];
 
  services.gnome.games.enable = false;
  services.gnome.core-developer-tools.enable = false;
  environment.gnome.excludePackages = with pkgs; [
    gnome-photos
    gnome-tour
    gnome.gnome-music
    gnome.gnome-calendar
    gnome.gnome-maps
    gnome.gedit
    gnome.epiphany
    gnome.geary
    gnome.evince
    gnome.totem
    gnome.cheese
    gnome.gnome-weather
    gnome.gnome-contacts
    gnome-text-editor
  ];

  # Configure keymap in X11
  services.xserver = {
    layout = "fr";
    xkbVariant = "oss_latin9";
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

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
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
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "docker" ];
    packages = with pkgs; [
      #firefox-wayland
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;


  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    neovim
    tailscale
    gnome.adwaita-icon-theme
    gnomeExtensions.appindicator
    gnomeExtensions.printers
    gnome.gnome-settings-daemon43
    gnomeExtensions.dashbar
    gnome.mutter
    gnomeExtensions.dash-to-panel
    gnome.dconf-editor
    gnomeExtensions.printers
    gnomeExtensions.user-themes
    avahi
  ];

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
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  system.stateVersion = "23.11"; # Did you read the comment?

}
