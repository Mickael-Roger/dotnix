{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [

    # Network
    nmap
    netsniff-ng
    mitmproxy
    tcpdump
    netcat-openbsd
    wireshark
    aircrack-ng
    bully

    # Web
    zap
    jwt-cli
    sqlmap
    graphqlmap
    dirbuster
    dirb
    cewl
    wfuzz
    bloomrpc
    davtest

    # General
    metasploit
    exploitdb
    burpsuite

    # Password cracking
    jwt-hack
    john
    hashcat

    # Reverse & pwn
    thc-hydra
    hydra-cli
    ghidra
    binwalk
    python311Packages.pwntools
    pwntools

    # Forensic
    volatility3
    sleuthkit

    # Stegano
    stegsolve

    # List
    seclists
    wordlists

    # OSINT
    holehe

#    postman
  ];
}
