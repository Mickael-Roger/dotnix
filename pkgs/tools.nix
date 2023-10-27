{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    jq
    file
    keepass
  ];
}
