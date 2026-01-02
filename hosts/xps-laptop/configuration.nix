# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, nur, ... }:

{
  imports =
    [ 
      ../../common/base.nix
      ../../common/pkgs/nix.nix
      ../../common/pkgs/cybersec.nix
      ../../common/pkgs/kube.nix
      ../../common/pkgs/web.nix
      ../../common/pkgs/tools.nix
      ../../common/pkgs/virtu.nix
      ../../common/pkgs/media.nix
      ../../common/pkgs/cloud.nix
      ../../common/pkgs/dev.nix
      ../../common/pkgs/maker.nix
    ];

  networking.hostName = "xps-mick"; 

  # Power management for laptop - don't sleep when on AC power
  powerManagement = {
    enable = true;
    # Don't suspend when lid is closed if external monitor is connected
    logind = {
      handleLidSwitch = "ignore";
      handleLidSwitchExternalPower = "ignore";
      handleLidSwitchDocked = "ignore";
    };
  };

  # Additional power settings to prevent sleep on AC power
  systemd.services."prevent-sleep-on-ac" = {
    description = "Prevent sleep when on AC power";
    wantedBy = [ "multi-user.target" ];
    script = ''
      #!${pkgs.bash}/bin/bash
      while true; do
        if [ "$(cat /sys/class/power_supply/AC/online 2>/dev/null || echo 0)" = "1" ]; then
          # On AC power, prevent sleep
          ${pkgs.systemd}/bin/systemd-inhibit --what=idle:sleep --why="On AC power" --mode=block sleep infinity
        fi
        sleep 60
      done
    '';
    serviceConfig = {
      Restart = "always";
      RestartSec = "5";
    };
  };

}
