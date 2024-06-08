{ config, pkgs, ... }:

{
  # For obsidian
  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
  ];
  environment.systemPackages = with pkgs; [
    dig
    git
    jq
    file
    keepass
    tldr
    encfs
    bcc
    bpftrace
    copyq
    ripgrep
    unzip
    usbutils
    socat
    lsof
    nerdfonts
    gedit
    tmux
    iotas
    thunderbird
    unrar
    zip
    jdk21

    yubikey-manager
    yubikey-manager-qt

    # Productivity
    anki-bin
    obsidian
    synology-drive-client
    #nextcloud-client
  ];

}
