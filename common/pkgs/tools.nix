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

  firefox-tui = pkgs.buildGoModule {
    pname = "firefox-tui";
    version = "v1.0";
    src = pkgs.fetchFromGitHub {
      owner = "Mickael-Roger";
      repo = "ff-tui";
      rev = "v1.0";
      sha256 = "sha256-6hurGmZkHIJcZAPRH4rf5pXE4TZZV0sAPA8L/6IoyC0=";
    };
    outputs = [ "out" ];
    installPhase = ''
      install -Dm755 $GOPATH/bin/firefox-tui $out/bin/firefox-tui
    '';
    vendorHash = "sha256-lKSr05aeK+HBxJKIbBPSesYpokf6D2Yol8p4OHHjNQ8=";
  };

  ffgo = pkgs.writeShellScriptBin "ff" ''
    ${firefox-tui}/bin/firefox-tui --command list | ${pkgs.fzf}/bin/fzf --delimiter=' ' --with-nth=2.. | ${pkgs.gawk}/bin/awk '{print $1}' | ${pkgs.findutils}/bin/xargs -I{} ${firefox-tui}/bin/firefox-tui --command go {}
  '';


  opencode = pkgs.writeScriptBin "opencode" ''
    #!${pkgs.runtimeShell}
    export PATH=${pkgs.nodejs_20}/bin:$PATH
    exec npx -y opencode-ai@latest "$@"
  '';

  gemini = pkgs.writeScriptBin "gemini" ''
    #!${pkgs.runtimeShell}
    export PATH=${pkgs.nodejs_20}/bin:$PATH
    exec npx -y https://github.com/google-gemini/gemini-cli "$@"
  '';

  n8n-mcp = pkgs.writeScriptBin "n8n-mcp" ''
    #!${pkgs.runtimeShell}
    export PATH=${pkgs.nodejs_20}/bin:$PATH
    exec npx -y n8n-mcp@latest "$@"
  '';

in {
  # For obsidian
  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
    "googleearth-pro-7.3.6.9796"
  ];
  environment.systemPackages = with pkgs; [
    # shortcut
    wifi-management
    bluetooth-management
    sound-management

    tom
    # Needed to manage windows into virtual desktop
    ffgo
    firefox-tui
    wmctrl 
   
    # AI
    #unstable.gemini-cli
    unstable.claude-code
    opencode
    gemini
    ## MCP
    n8n-mcp


    pkgs.xfce.thunar


    pkgs.dig
    pkgs.git
    pkgs.jq
    pkgs.file
    pkgs.keepass
    pkgs.tldr
    pkgs.encfs
    pkgs.bcc
    pkgs.bpftrace
    pkgs.copyq
    pkgs.ripgrep
    pkgs.unzip
    pkgs.usbutils
    pkgs.socat
    pkgs.lsof
    #pkgs.nerdfonts
    pkgs.gedit
    pkgs.tmux
    pkgs.tmux-mem-cpu-load
    pkgs.tig
    pkgs.iotas
    pkgs.thunderbird
    pkgs.unrar
    pkgs.zip
    pkgs.p7zip
    pkgs.jdk21
    pkgs.ffmpeg
    pkgs.openssl
    pkgs.inotify-tools
    pkgs.
    pkgs.googleearth-pro

    pkgs.yubikey-manager
    pkgs.yubikey-manager-qt

    pkgs.sqlite

    pkgs.wl-clipboard

    pkgs.ugrep

    # Productivity
    pkgs.anki-bin
    pkgs.obsidian
    #pkgs.synology-drive-client
    #pkgs.nextcloud-client
  ];

}
