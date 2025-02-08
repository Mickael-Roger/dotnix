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
    tmux-mem-cpu-load
    tig
    iotas
    thunderbird
    unrar
    zip
    p7zip
    jdk21
    ffmpeg
    openssl

    yubikey-manager
    yubikey-manager-qt

    sqlite

    wl-clipboard

    # Productivity
    anki-bin
    obsidian
    #synology-drive-client
    #nextcloud-client
  ];

}
