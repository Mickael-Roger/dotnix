{ config, pkgs, ctfmgntSrc, ... }:
let

    ctfmgnt =  pkgs.callPackage "${ctfmgntSrc}/derivation.nix" {};

in {
  environment.systemPackages = with pkgs; [

    ctfmgnt

    # Network
    nmap
    netsniff-ng
    mitmproxy
    tcpdump
    netcat-openbsd
    wireshark
    aircrack-ng
    bully
    python312Packages.scapy

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
    gef

    # Divers
    gnuradio

    # Forensic
    volatility3
    sleuthkit

    # Stegano
    stegsolve
    steghide
    stegseek
    zsteg
    foremost


    # List
    seclists
    wordlists

    # OSINT
    holehe

#    postman
  ];
}
