{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    jq
    file
    keepass
    tldr
    encfs
    bcc
    copyq
    ripgrep
    unzip
  ];

}
