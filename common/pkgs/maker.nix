{ config, pkgs, unstable, ... }:
let

  creality-print = pkgs.appimageTools.wrapType2 {
    pname = "creality-print"; 
    version = "v5.1.17";
    src = pkgs.fetchurl {
      url = "https://github.com/CrealityOfficial/CrealityPrint/releases/download/v5.1.7/Creality_Print-v5.1.7.10514-x86_64-Release.AppImage";
      hash = "sha256-IrVBlNbYs/Lmb9y8Yb/Xfpz+Rsx56nmK+4GkuMHh9zc=";
    };
  };

  esp32-idf-full = pkgs.writeShellScriptBin "esp32-idf-full"
  ''
    ${pkgs.nix}/bin/nix develop github:mirrexagon/nixpkgs-esp-dev#esp-idf-full
  '';
 
  esp32-idf = pkgs.writeShellScriptBin "esp32-idf"
  ''
    ${pkgs.nix}/bin/nix develop github:mirrexagon/nixpkgs-esp-dev#esp32-idf
  '';
      
  esp32c3-idf = pkgs.writeShellScriptBin "esp32c3-idf"
  ''
    ${pkgs.nix}/bin/nix develop github:mirrexagon/nixpkgs-esp-dev#esp32c3-idf
  '';
 

  esp32s2-idf = pkgs.writeShellScriptBin "esp32s2-idf"
  ''
    ${pkgs.nix}/bin/nix develop github:mirrexagon/nixpkgs-esp-dev#esp32s2-idf
  '';
 

  esp32s3-idf = pkgs.writeShellScriptBin "esp32s3-idf"
  ''
    ${pkgs.nix}/bin/nix develop github:mirrexagon/nixpkgs-esp-dev#esp32s3-idf
  '';
 

  esp32c6-idf = pkgs.writeShellScriptBin "esp32c6-idf"
  ''
    ${pkgs.nix}/bin/nix develop github:mirrexagon/nixpkgs-esp-dev#esp32c6-idf
  '';
 

  esp32h2-idf = pkgs.writeShellScriptBin "esp32h2-idf"
  ''
    ${pkgs.nix}/bin/nix develop github:mirrexagon/nixpkgs-esp-dev#esp32h2-idf
  '';
 
  esp8266-rtos-idf = pkgs.writeShellScriptBin "esp8266-rtos-idf"
  ''
    ${pkgs.nix}/bin/nix develop github:mirrexagon/nixpkgs-esp-dev#esp8266-rtos-sdk
  '';
 

  
in {
  environment.systemPackages = with pkgs; [
    creality-print
    freecad
    #pkgs.freecad-wayland
    arduino
    sweethome3d.application
    sweethome3d.textures-editor
    sweethome3d.furniture-editor
    esptool
    kicad

    thonny

    openscad
    openscad-lsp

    stm32cubemx
    openocd
    #pkgs.gcc-arm-embedded-13
    gcc-arm-embedded

    rpi-imager

    esp32-idf-full
    esp32-idf
    esp32c3-idf
    esp32s2-idf
    esp32s3-idf
    esp32c6-idf
    esp32h2-idf
    esp8266-rtos-idf


    gst_all_1.gstreamer
    gst_all_1.gst-rtsp-server
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-libav
  ];
}
