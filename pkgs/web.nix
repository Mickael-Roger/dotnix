{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    firefox-wayland
  ];
  
  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    # only needed for Sway
    XDG_CURRENT_DESKTOP = "sway"; 
  };


}
