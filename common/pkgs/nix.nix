{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    nix-tree
    home-manager
  ];
}
