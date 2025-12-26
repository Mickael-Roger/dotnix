{ config, pkgs, inputs, yt-x, ... }:

{
  environment.systemPackages = with pkgs; [
    vlc
    totem
    drawio
    libreoffice
    kdePackages.okular
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
    yt-x.packages."${system}".default
  ];
}
