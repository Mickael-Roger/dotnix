{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    vlc
    drawio
    libreoffice
    okular
    weechat
    discord
    tuba
    slack
    imagemagick
    evince
  ];
}
