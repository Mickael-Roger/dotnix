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
    bpftrace
    copyq
    ripgrep
    unzip
  ];

}
