{ config, pkgs, ... }:
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
    pname = "tom";
    version = "v0.1";
    src = pkgs.fetchFromGitHub {
      owner = "Mickael-Roger";
      repo = "tom";
      rev = "v0.1";
      sha256 = "sha256-uIzCu5ey2rYDoBOCfx+FUGR3WfDcLxPdYkXv/4oIypc=";
    };
    outputs = [ "out" ];
    installPhase = ''
      install -Dm755 $GOPATH/bin/tui $out/bin/tom
    '';
    modRoot = "tui";
    vendorHash = "sha256-hGDjFrz88pq3n0tbGIrMS6KzQqV83ey485+NTbko8iI=";
  };

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
   
    # AI
    pkgs.gemini-cli

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
