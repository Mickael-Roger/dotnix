{ config, pkgs, ... }:
let

    ctfmgntSrc = pkgs.fetchFromGitHub { owner = "Mickael-Roger"; repo = "ctf-mgnt"; rev = "main"; sha256 = "sha256-ozBFVVDt7gwbxM2RDEGTeb3igAcyjOjYPEf7wcbIvhI="; };
    ctfmgnt =  pkgs.callPackage (ctfmgntSrc + "/derivation.nix") {};

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
