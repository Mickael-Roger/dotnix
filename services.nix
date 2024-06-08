{ config, pkgs, ... }:
let
   secrets = import ./secrets.nix;
in
{

  systemd.services.anki = {
    enable = true;
    environment = {
      SYNC_USER1 = "mickael:${secrets.anki.mickael.password}";
      SYNC_USER2 = "ambre:${secrets.anki.ambre.password}";
      SYNC_USER3 = "charlotte:${secrets.anki.charlotte.password}";
      SYNC_BASE = "/home/mickael/SynologyDrive/Anki";
    };
    serviceConfig = {
       ExecStart = "${pkgs.anki-bin}/bin/anki --syncserver";
       User = "mickael";
     };
  };

  users.groups.nextcloud = {
    gid = 33;
  };
 
  users.users.mickael.extraGroups = [ "nextcloud" ];

  networking.firewall.allowedTCPPorts = [
    443
  ];

  services.nginx.enable = true;
  services.nginx.virtualHosts = {
      "server.taila2494.ts.net" = {
        locations."/".proxyPass = "http://127.0.0.1:80/";
        sslCertificate = "/etc/certs/server.taila2494.ts.net.crt";
        sslCertificateKey = "/etc/certs/server.taila2494.ts.net.key";
        onlySSL = true;
        #listen = [{
        #  addr = "0.0.0.0";
        #  port = 443;
        #  ssl = true;
        #}];
      };
    };

  systemd.timers."update-news" = {
    wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "15m";
        OnUnitActiveSec = "15m";
        Unit = "update-news.service";
      };
  };
  
  systemd.services."update-news" = {
    script = ''
      ${pkgs.docker}/bin/docker exec -u 33 -i nextcloud /var/www/html/occ news:updater:before-update
      ${pkgs.docker}/bin/docker exec -u 33 -i nextcloud /var/www/html/occ news:updater:update-user mickael
      ${pkgs.docker}/bin/docker exec -u 33 -i nextcloud /var/www/html/occ news:updater:after-update
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "mickael";
    };
  };


  systemd.services.nextcloud = {
    description = "Nextcloud";
    wantedBy = [ "multi-user.target" ];
    after = [ "docker.service" "docker.socket" ];
    requires = [ "docker.service" "docker.socket" ];
    script = ''
      exec ${pkgs.docker}/bin/docker run \
          --name=nextcloud \
          --network=host \
          -v /home/mickael/SynologyDrive/Nextcloud/:/var/www/ \
          -v /home/mickael/SynologyDrive/Nextcloud/data/:/var/www/data/ \
          -v /home/mickael/SynologyDrive/Nextcloud/html/:/var/www/html/ \
          nextcloud:stable-apache
    '';
    preStop = "${pkgs.docker}/bin/docker stop nextcloud";
    reload = "${pkgs.docker}/bin/docker restart nextcloud";
    serviceConfig = {
      ExecStartPre = "-${pkgs.docker}/bin/docker rm -f nextcloud";
      ExecStopPost = "-${pkgs.docker}/bin/docker rm -f nextcloud";
      TimeoutStartSec = 0;
      TimeoutStopSec = 120;
      Restart = "always";
    };
  };

}
