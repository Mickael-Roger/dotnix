{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    cura
    freecad
    arduino
    sweethome3d.application
    sweethome3d.textures-editor
    sweethome3d.furniture-editor 
    esptool
  ];
}
