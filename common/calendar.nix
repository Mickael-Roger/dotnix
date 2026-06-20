{ pkgs, ... }:

{
  services.vdirsyncer = {
    enable = true;

    jobs.ovh = {
      enable = true;
      user = "mickael";
      group = "users";

      timerConfig = {
        OnBootSec = "5m";
        OnUnitActiveSec = "5m";
      };

      configFile = pkgs.writeText "vdirsyncer-ovh.ini" ''
        [general]
        status_path = "~/.local/share/vdirsyncer/status"

        [storage ovh]
        type = "caldav"
        url = "https://zimbra1.mail.ovh.net/dav/mickael@famille-roger.com/"
        username = "mickael@famille-roger.com"
        password.fetch = ["shell", " cat ~/.config/vdirsync.passwd"]
        item_types = ["VEVENT", "VTODO"]

        [storage local_cal]
        type = "filesystem"
        path = "~/.local/share/vdirsyncer/calendars"
        fileext = ".ics"

        [storage local_tasks]
        type = "filesystem"
        path = "~/.local/share/vdirsyncer/tasks"
        fileext = ".ics"

        [pair calendars]
        a = "local_cal"
        b = "ovh"
        collections = ["Calendar", "Famille"]
        conflict_resolution = "b wins"
        metadata = ["color", "displayname"]

        [pair tasks]
        a = "local_tasks"
        b = "ovh"
        collections = ["Todo"]
        conflict_resolution = "b wins"
        metadata = ["color", "displayname"]
      '';
    };
  };
}
