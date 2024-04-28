{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    nmap
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
    tcpdump
    netcat-openbsd
    graphqlmap
    wireshark
    volatility3
    stegsolve
    dirbuster
    seclists
    dirb
    cewl
  ];
}
