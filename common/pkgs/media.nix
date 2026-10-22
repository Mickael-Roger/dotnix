{ config, pkgs, inputs, yt-x, unstable, ... }:

{
  environment.systemPackages = with pkgs; [
    vlc
    totem
    drawio
    libreoffice
    kdePackages.okular
    weechat
    discord
    unstable.concord-tui
    tuba
    slack
    imagemagick
    evince
    exiftool
    newsflash
    freetube
    yt-x.packages."${pkgs.stdenv.hostPlatform.system}".default
  ];
}
