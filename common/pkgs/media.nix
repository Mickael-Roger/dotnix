{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    vlc
    totem
    drawio
    libreoffice
    libsForQt5.okular
    weechat
    discord
    tuba
    slack
    imagemagick
    evince
    exiftool
    newsflash
    freetube
    vdhcoapp
  ];
}
