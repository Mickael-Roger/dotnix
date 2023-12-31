{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    docker
    go
    gopls
    delve
    gomodifytags
    impl
    gotests
    iferr
    borg-sans-mono
    rnix-lsp
    ansible-language-server
    gdb
    gef
    gcc
    cmake
    gnumake
    protobuf
    tinygo
    wazero
    nixd
    wasmer
    wabt
  ];
}
