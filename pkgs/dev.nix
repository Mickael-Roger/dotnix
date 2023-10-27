{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    go
    gdb
    gef
    gcc
    cmake
  ];
}
