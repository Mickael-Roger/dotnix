{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    go
    gopls
    gdb
    gef
    gcc
    cmake
    gnumake
  ];
}
