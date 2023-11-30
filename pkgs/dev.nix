{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    go
    gopls
    rnix-lsp
    ansible-language-server
    gdb
    gef
    gcc
    cmake
    gnumake
    protobuf
  ];
}
