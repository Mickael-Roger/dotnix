{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    #firefox-wayland
    firefox
    google-chrome
  ];
  
  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "0";
    # only needed for Sway
    #XDG_CURRENT_DESKTOP = "sway"; 
  };


}
