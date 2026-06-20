{ pkgs, ... }:

{
  networking.networkmanager.enable = true;

  services.avahi = {
    enable = true;
    openFirewall = true;
  };

  services.tailscale.enable = true;

  services.openssh.enable = true;
  services.openssh.settings.X11Forwarding = true;
  services.openssh.settings.X11DisplayOffset = 10;
  services.openssh.settings.X11UseLocalhost = true;

  networking.firewall.allowedTCPPorts = [ 8444 4444 3306 ];

  environment.systemPackages = with pkgs; [
    avahi
    tailscale
  ];
}
