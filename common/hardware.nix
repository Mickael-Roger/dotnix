{ pkgs, ... }:

{
  services.pcscd.enable = true;

  services.printing = {
    enable = true;
    drivers = [ pkgs.epson-escpr ];
  };

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="55d3", MODE="0666", GROUP="dialout"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="38fb", ATTRS{idProduct}=="1001", MODE="0666", GROUP="dialout"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="38fb", ATTRS{idProduct}=="1002", MODE="0660", GROUP="dialout"
  '';
}
