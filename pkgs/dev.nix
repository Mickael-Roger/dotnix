{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    go
    gopls
    rnix-lsp
    gdb
    gef
    gcc
    cmake
    gnumake
  ];
}
