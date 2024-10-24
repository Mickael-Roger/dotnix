# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, nur, ... }:

{
  imports =
    [ 
      ../../common/base.nix
      ../../common/services.nix
      ../../common/pkgs/cybersec.nix
      ../../common/pkgs/nix.nix
      ../../common/pkgs/kube.nix
      ../../common/pkgs/web.nix
      ../../common/pkgs/tools.nix
      ../../common/pkgs/virtu.nix
      ../../common/pkgs/media.nix
      ../../common/pkgs/cloud.nix
      ../../common/pkgs/dev.nix
      ../../common/pkgs/maker.nix
    ];

  networking.hostName = "server"; 


}
