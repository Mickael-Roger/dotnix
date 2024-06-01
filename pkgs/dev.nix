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
    ansible-language-server
    gdb
    gef
    gcc
    python3
    python311Packages.pip
    python310Packages.pip
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
