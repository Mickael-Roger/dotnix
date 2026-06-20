{ config, pkgs, secretSrc, ... }:
let
  secrets = import "${secretSrc}/secrets.nix";

in
{

  networking.firewall.allowedTCPPorts = [
    443
    8443
    8444
  ];

  services.nginx.enable = true;
  services.nginx.virtualHosts = {
    "litellm" = {
      locations."/".proxyPass = "http://127.0.0.1:4000/";
      sslCertificate = "/etc/certs/server.taila2494.ts.net.crt";
      sslCertificateKey = "/etc/certs/server.taila2494.ts.net.key";
      onlySSL = true;
      listen = [{
        addr = "0.0.0.0";
        port = 443;
        ssl = true;
      }];
    };
  };


  services.znc = {
    enable = true;
    mutable = false;
    useLegacyConfig = false;
    openFirewall = true;

    config = {
      LoadModule = [ "adminlog" ];

      User.mickael = {
        Admin = true;
        Pass.password = {
          Method = "sha256";
          Hash = "${secrets.libera.admin_hash}";
        };

        Network.libera = {
          Server = "irc.libera.chat +6697";
          Nick = "MickaelR";
          Settings = {
            sasl = {
              Mechanism = "PLAIN";
              Username = "${secrets.libera.user}";
              Password = "${secrets.libera.password}";
            };
          };
          LoadModule = [ "sasl" "nickserv" ];
        };
      };
    };
  };

  systemd.services.syno-backup = {
    description = "Backup /data to synology";
    path = [ pkgs.openssh ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.sshpass}/bin/sshpass -p '${secrets.rsync}' ${pkgs.rsync}/bin/rsync -a /data/ backup@192.168.1.199:";
    };
    wantedBy = [ "timers.target" ];
  };

  systemd.timers.syno-backup = {
    description = "Backup /data to Synology every 1h";
    timerConfig = {
      OnCalendar = "hourly";
      Persistent = true;
    };
    wantedBy = [ "timers.target" ];
  };

}
