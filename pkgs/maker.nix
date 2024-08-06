{ config, pkgs, ... }:
let
  esp32-idf-src = builtins.fetchGit {
    url = "https://github.com/mirrexagon/nixpkgs-esp-dev.git";
  };

  esp32-idf-full = pkgs.writeShellScriptBin "esp32-idf-full"
  ''
    ${pkgs.nix}/bin/nix-shell ${esp32-idf-src}/shells/esp-idf-full.nix
  '';
 
  esp32-idf = pkgs.writeShellScriptBin "esp32-idf"
  ''
    ${pkgs.nix}/bin/nix-shell ${esp32-idf-src}/shells/esp32-idf.nix
  '';
      
  esp32c3-idf = pkgs.writeShellScriptBin "esp32c3-idf"
  ''
    ${pkgs.nix}/bin/nix-shell ${esp32-idf-src}/shells/esp32c3-idf.nix
  '';
 

  esp32s2-idf = pkgs.writeShellScriptBin "esp32s2-idf"
  ''
    ${pkgs.nix}/bin/nix-shell ${esp32-idf-src}/shells/esp32s2-idf.nix
  '';
 

  esp32s3-idf = pkgs.writeShellScriptBin "esp32s3-idf"
  ''
    ${pkgs.nix}/bin/nix-shell ${esp32-idf-src}/shells/esp32s3-idf.nix
  '';
 

  esp32c6-idf = pkgs.writeShellScriptBin "esp32c6-idf"
  ''
    ${pkgs.nix}/bin/nix-shell ${esp32-idf-src}/shells/esp32c6-idf.nix
  '';
 

  esp32h2-idf = pkgs.writeShellScriptBin "esp32h2-idf"
  ''
    ${pkgs.nix}/bin/nix-shell ${esp32-idf-src}/shells/esp32h2-idf.nix
  '';
 
  esp8266-rtos-idf = pkgs.writeShellScriptBin "esp8266-rtos-idf"
  ''
    ${pkgs.nix}/bin/nix-shell ${esp32-idf-src}/shells/esp8266-rtos-sdk.nix
  '';
 

  
in {
  environment.systemPackages = [
    pkgs.cura
    pkgs.freecad
    pkgs.arduino
    pkgs.sweethome3d.application
    pkgs.sweethome3d.textures-editor
    pkgs.sweethome3d.furniture-editor 
    pkgs.esptool
    pkgs.kicad

    pkgs.stm32cubemx
    pkgs.openocd
    pkgs.gcc-arm-embedded-13

    pkgs.rpi-imager

    esp32-idf-full
    esp32-idf
    esp32c3-idf
    esp32s2-idf
    esp32s3-idf
    esp32c6-idf
    esp32h2-idf
    esp8266-rtos-idf
  ];
}
