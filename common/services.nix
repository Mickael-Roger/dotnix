{ config, pkgs, secretSrc, ... }:
let
  secrets = import "${secretSrc}/secrets.nix";

  passbolt-compose = pkgs.writeTextFile {
    name = "passbolt-compose";
    text = ''
      version: "3.9"
      services:
        #db:
        #  image: mariadb:10.11
        #  restart: unless-stopped
        #  environment:
        #    MYSQL_RANDOM_ROOT_PASSWORD: "true"
        #    MYSQL_DATABASE: "passbolt"
        #    MYSQL_USER: "passbolt"
        #    MYSQL_PASSWORD: "${secrets.passbolt.password}"
        #  volumes:
        #    - /data/passbolt/mysql:/var/lib/mysql
      
        passbolt:
          image: passbolt/passbolt:latest-ce
          restart: unless-stopped
          #depends_on:
          #  - db
          environment:
            APP_FULL_BASE_URL: https://server.taila2494.ts.net:8443
            DATASOURCES_DEFAULT_HOST: "host.docker.internal"
            DATASOURCES_DEFAULT_USERNAME: "passbolt"
            DATASOURCES_DEFAULT_PASSWORD: "${secrets.passbolt.password}"
            DATASOURCES_DEFAULT_DATABASE: "passbolt"
          volumes:
            - /data/passbolt/gpg_volume:/etc/passbolt/gpg
            - /data/passbolt/jwt_volume:/etc/passbolt/jwt
          extra_hosts:
            - "host.docker.internal:host-gateway"
          command:
            [
              "/usr/bin/wait-for.sh",
              "-t",
              "0",
              "host.docker.internal:3306",
              "--",
              "/docker-entrypoint.sh",
            ]
          ports:
            - 8081:80
    '';
  };

in
{

  systemd.services.anki = {
    enable = true;
    environment = {
      SYNC_USER1 = "mickael:${secrets.anki.mickael.password}";
      SYNC_USER2 = "ambre:${secrets.anki.ambre.password}";
      SYNC_USER3 = "charlotte:${secrets.anki.charlotte.password}";
      SYNC_USER4 = "test:${secrets.anki.test.password}";
      SYNC_BASE = "/data/Anki";
    };
    serviceConfig = {
       ExecStart = "${pkgs.anki-bin}/bin/anki --syncserver";
       User = "mickael";
    };
    wantedBy = ["multi-user.target"];
    after = [ "network.target" ];
  };


##  services.anki-sync-server = {
##    enable = true;
##    port = 8082;
##    users = [
##      {
##       username = "mickael"; 
##       password = "${secrets.anki.mickael.password}";
##      }
##    ];
##    openFirewall = true;
##  };

  users.groups.nextcloud = {
    gid = 33;
  };
 
  users.users.mickael.extraGroups = [ "nextcloud" ];

  networking.firewall.allowedTCPPorts = [
    443
    8443
    8444
  ];

  services.nginx.enable = true;
  services.nginx.virtualHosts = {
      "nextcloud" = {
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
      "passbolt" = {
        locations."/".proxyPass = "http://127.0.0.1:8081/";
        sslCertificate = "/etc/certs/server.taila2494.ts.net.crt";
        sslCertificateKey = "/etc/certs/server.taila2494.ts.net.key";
        onlySSL = true;
        listen = [{
          addr = "0.0.0.0";
          port = 8443;
          ssl = true;
        }];
      };
      "tom" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:8082/";
          extraConfig = ''
            proxy_connect_timeout 60s;
            proxy_send_timeout 120s;
            proxy_read_timeout 300s;
            send_timeout 300s;
          '';
        };
        sslCertificate = "/etc/certs/server.taila2494.ts.net.crt";
        sslCertificateKey = "/etc/certs/server.taila2494.ts.net.key";
        onlySSL = true;
        listen = [{
          addr = "0.0.0.0";
          port = 8444;
          ssl = true;
        }];
      };
   };

#  services.nextcloud = {
#    enable = true;
#    hostName = "server.taila2494.ts.net";
#    home = "/home/nextcloud";
#    package = pkgs.nextcloud28;
#    config = {
#      dbtype = "sqlite";
#      adminpassFile = "/tmp/toto";
#    };
#    extraApps = {
#      inherit (pkgs.nextcloud28Packages.apps) contacts calendar tasks;
#    };
#    extraAppsEnable = true;
#  };


  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    dataDir = "/data/mysql/";
    settings = {
      mysqld = {
        bind-address = "127.0.0.1,172.17.0.1";
      };
    };
    initialDatabases = [
      { name = "nextcloud"; }
      { name = "passbolt"; }
    ];
    ensureUsers = [
      {
        name = "nextcloud";
        ensurePermissions = {
          "nextcloud.*" = "ALL PRIVILEGES";
        };
      }
      {
        name = "passbolt";
        ensurePermissions = {
          "passbolt.*" = "ALL PRIVILEGES";
        };
      }
    ];
  };

  services.mysqlBackup = {
    enable = true;
    location = "/data/backup/mysql";
    calendar = "01:00:00";
    databases = [ "mysql" "passbolt" "nextcloud" ];
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


  #systemd.timers."update-news" = {
  #  wantedBy = [ "timers.target" ];
  #    timerConfig = {
  #      OnBootSec = "15m";
  #      OnUnitActiveSec = "15m";
  #      Unit = "update-news.service";
  #    };
  #};
  #
  #systemd.services."update-news" = {
  #  script = ''
  #    ${pkgs.docker}/bin/docker exec -u 33 -i nextcloud /var/www/html/occ news:updater:before-update
  #    ${pkgs.docker}/bin/docker exec -u 33 -i nextcloud /var/www/html/occ news:updater:update-user mickael
  #    ${pkgs.docker}/bin/docker exec -u 33 -i nextcloud /var/www/html/occ news:updater:after-update
  #  '';
  #  serviceConfig = {
  #    Type = "oneshot";
  #    User = "mickael";
  #  };
  #};

  systemd.services.tom = {
    description = "Tom";
    wantedBy = [ "multi-user.target" ];
    after = [ "docker.service" "docker.socket" ];
    requires = [ "docker.service" "docker.socket" ];
    script = ''
      exec ${pkgs.docker}/bin/docker run \
          -e "TZ=Europe/Paris" \
          --name=tom \
          --network=host \
          -v /etc/localtime:/etc/localtime:ro \
          -v /data/tom/:/data/ \
          tom:current
    '';
    preStop = "${pkgs.docker}/bin/docker stop tom";
    reload = "${pkgs.docker}/bin/docker restart tom";
    serviceConfig = {
      ExecStartPre = [
        "-${pkgs.docker}/bin/docker rm -f tom"
        "-${pkgs.docker}/bin/docker image prune -f"
      ];
      ExecStopPost = "-${pkgs.docker}/bin/docker rm -f tom";
      TimeoutStartSec = 0;
      TimeoutStopSec = 120;
      Restart = "always";
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

  systemd.services.nextcloud-update = {
    description = "Run cron nextcloud update";
    serviceConfig = {
      Type = "oneshot";
      ExecCondition = "${pkgs.docker}/bin/docker exec -t -u www-data nextcloud php -f /var/www/html/occ status -e";
      ExecStart = "${pkgs.docker}/bin/docker exec -t -u www-data nextcloud php -f /var/www/html/cron.php";
    };
    wantedBy = [ "timers.target" ];
  };

  systemd.timers.nextcloud-update = {
    description = "Run nextcloud cron update every 10 minutes";
    timerConfig = {
      OnCalendar = "*:0/10";
      Persistent = true;
    };
    wantedBy = [ "timers.target" ];
    requires = [ "nextcloud.service" ];
    after = [ "nextcloud.service" ];
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
          -v /data/Nextcloud/:/var/www/ \
          -v /data/Nextcloud/data/:/var/www/data/ \
          -v /data/Nextcloud/html/:/var/www/html/ \
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

  systemd.services.passbolt = {
    description = "passbolt";
    wantedBy = [ "multi-user.target" ];
    after = [ "docker.service" "docker.socket" ];
    requires = [ "docker.service" "docker.socket" ];
    serviceConfig = {
      ExecStart = "${pkgs.docker-compose}/bin/docker-compose -f ${passbolt-compose} up";
      ExecStop = "${pkgs.docker-compose}/bin/docker-compose -f ${passbolt-compose} down";
      TimeoutStartSec = 0;
      TimeoutStopSec = 120;
      Restart = "always";
    };
  };

  services.home-assistant = {
    enable = true;
    extraComponents = [
      "esphome"
    ];

    extraPackages = python3Packages: with python3Packages; [
      androidtvremote2
      pychromecast
      freebox-api
    ];

    config = {
      default_config = {};
    };
  };

  services.esphome.enable = true;
  
}
