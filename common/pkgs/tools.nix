{ config, pkgs, unstable, ... }:
let

  wifi-management = pkgs.writeShellScriptBin "wifi-management" ''
    XDG_CURRENT_DESKTOP=gnome ${pkgs.gnome-control-center}/bin/gnome-control-center wifi
  '';

  sound-management = pkgs.writeShellScriptBin "sound-management" ''
    XDG_CURRENT_DESKTOP=gnome ${pkgs.gnome-control-center}/bin/gnome-control-center sound
  '';

  bluetooth-management = pkgs.writeShellScriptBin "bluetooth-management" ''
    ${pkgs.blueman}/bin/blueman-manager
  '';

  tom = pkgs.buildGoModule {
    pname = "tom-tui";
    version = "v1.7";
    src = pkgs.fetchFromGitHub {
      owner = "Mickael-Roger";
      repo = "tom-tui";
      rev = "v1.7";
      sha256 = "sha256-VkdG6xc6JtBIONmQ1Z/aPEYjv61C3rIg9yQME9DrGhA=";
    };
    outputs = [ "out" ];
    installPhase = ''
      install -Dm755 $GOPATH/bin/tui $out/bin/tom
    '';
    vendorHash = "sha256-kswhENk3y0Dew0cpCy8ff3hNbglBYxLYSxW0fIT6img=";
  };


  opencode = pkgs.writeScriptBin "opencode" ''
    #!${pkgs.runtimeShell}
    export PATH=${pkgs.nodejs_22}/bin:$PATH
    exec npx -y opencode-ai@latest "$@"
  '';

  ocm = pkgs.writeScriptBin "ocm" ''
    #!${pkgs.runtimeShell}
    export PATH=${pkgs.nodejs_22}/bin:$PATH
    exec npx -y @mickaelroger78/opencode-manager@latest "$@"
  '';


in {
  environment.systemPackages = with pkgs; [
    sshfs
    # shortcut
    wifi-management
    bluetooth-management
    sound-management

    tom
    # Needed to manage windows into virtual desktop
    wmctrl 

    # Tooling
    xclip
   
    # AI
    #unstable.gemini-cli
    #unstable.claude-code
    opencode
    ocm
    #gemini
    llm
    python313Packages.llm-mistral
    python313Packages.llm-openrouter

    ## MCP
    yt-dlp

    thunar


    fzf

    podman
    podman-compose


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
    #pkgs.nerdfonts
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
    inotify-tools

    yubikey-manager

    sqlite-interactive

    wl-clipboard

    ugrep

    # Productivity
    anki-bin
    obsidian
    basalt
    khal
    todoman
    #pkgs.synology-drive-client
    #pkgs.nextcloud-client
  ];

}
