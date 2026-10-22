{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    #firefox-wayland
    firefox
    google-chrome
  ];

  environment.etc."opt/chrome/policies/managed/extensions.json".text = builtins.toJSON {
    ExtensionInstallForcelist = [
      "cjpalhdlnbpafiamejdnhcphjbkeiagm;https://clients2.google.com/service/update2/crx" # ublock origin
      "baahncfnjojaofhdmdfkpeadigoemkif;https://clients2.google.com/service/update2/crx" # Voicewave chatgpt
      "ameajnciachbdcneinbgnehihjolepkd;https://clients2.google.com/service/update2/crx" # Voicewave bard
    ];
  };
  
  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "0";
    # only needed for Sway
    #XDG_CURRENT_DESKTOP = "sway"; 
  };


}
