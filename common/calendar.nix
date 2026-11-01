{ pkgs, secretSrc, ... }:

let
  secrets = import "${secretSrc}/secrets.nix";
  vdirsyncerConfig = pkgs.writeText "vdirsyncer-ovh.ini" (
    builtins.replaceStrings [ "@OVH_EMAIL@" ] [ secrets.mail.ovh.email ]
      (builtins.readFile ./config-files/vdirsyncer/config)
  );
in

{
  services.vdirsyncer = {
    enable = true;

    jobs.ovh = {
      enable = true;
      forceDiscover = true;
      user = "mickael";
      group = "users";

      timerConfig = {
        OnBootSec = "5m";
        OnUnitActiveSec = "5m";
      };

      configFile = vdirsyncerConfig;
    };
  };

  systemd.tmpfiles.rules = [
    "d /data/calendars 0750 mickael users -"
    "d /data/tasks 0750 mickael users -"
    "d /data/contacts 0750 mickael users -"
  ];

  systemd.services."vdirsyncer@ovh".serviceConfig.ReadWritePaths = [
    "/data/calendars"
    "/data/tasks"
    "/data/contacts"
  ];
}
