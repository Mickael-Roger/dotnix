{ pkgs, ... }:

{
  programs.dconf.enable = true;

  services.xserver = {
    enable = true;
    xkb.layout = "fr";
    xkb.variant = "oss_latin9";
  };

  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.desktopManager.cosmic.enable = true;
  hardware.graphics.enable = true;

  programs.hyprland.enable = false;
  programs.sway.enable = false;
  programs.xwayland.enable = true;

  services.udev.packages = with pkgs; [ gnome-settings-daemon ];

  services.gnome.games.enable = false;
  services.gnome.core-developer-tools.enable = false;
  services.gnome.gnome-settings-daemon.enable = true;
  environment.gnome.excludePackages = with pkgs; [
    gnome-photos
    gnome-tour
    gnome-music
    gnome-calendar
    gnome-maps
    #gnome.gedit
    epiphany
    geary
    evince
    totem
    cheese
    gnome-weather
    gnome-contacts
    gnome-text-editor
  ];

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  environment.systemPackages = with pkgs; [
    hyprland
    wofi
    kitty
    waybar
    xwayland
    terminator
    adwaita-icon-theme
    gnomeExtensions.appindicator
    gnomeExtensions.printers
    gnome-settings-daemon
    gnomeExtensions.dashbar
    mutter
    gnomeExtensions.dash-to-panel
    dconf-editor
    gnomeExtensions.user-themes
    gnomeExtensions.dash-to-dock
    gnomeExtensions.forge
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono
    nerd-fonts.noto
    nerd-fonts.hack
    nerd-fonts.ubuntu
  ];
}
