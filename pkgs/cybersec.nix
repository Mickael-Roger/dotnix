{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    zap
    metasploit
    jwt-cli
    jwt-hack
    john
    thc-hydra
    hydra-cli
    ghidra
    exploitdb
    burpsuite
    sqlmap
    mitmproxy
    hashcat
#    postman
    bloomrpc
    davtest
  ];
}
