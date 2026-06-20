{ pkgs, nur, secretSrc, ... }:
let
  secrets = import "${secretSrc}/secrets.nix";
  ssh-connect = pkgs.writeShellScriptBin "ssh-connect" ''
    #!/bin/bash

    HOSTS=$(${pkgs.gawk}/bin/awk '/^Host / {for (i=2; i<=NF; i++) print $i}' ~/.ssh/config | ${pkgs.coreutils-full}/bin/sort)
    
    if [ -z "$HOSTS" ]; then
        echo "No host found"
        exit 1
    fi
    
    export FZF_DEFAULT_OPTS="--height=150 --border=rounded --layout=reverse --info=hidden --prompt='SSH Hosts: ' --preview-window=hidden --margin=5,10"

    SELECTED_HOST=$(echo "$HOSTS" | ${pkgs.fzf}/bin/fzf)
    
    if [ -n "$SELECTED_HOST" ]; then
        ${pkgs.tmux}/bin/tmux rename-window "ssh $SELECTED_HOST"
        echo "Connect to $SELECTED_HOST ..."
        ssh "$SELECTED_HOST"
    fi
  '';


  goto-window = pkgs.writeShellScriptBin "goto-window" ''
    ${pkgs.wmctrl}/bin/wmctrl -l | ${pkgs.gawk}/bin/awk '{printf $1" "; for(i=4;i<=NF;i++) printf $i" "; print ""}' | ${pkgs.fzf}/bin/fzf  --delimiter=' ' --with-nth=2.. | ${pkgs.gawk}/bin/awk '{print $1}' | ${pkgs.findutils}/bin/xargs -I{} ${pkgs.wmctrl}/bin/wmctrl -i -a {}
  '';

  goto-ff = pkgs.writeShellScriptBin "goto-ff" ''
    ${pkgs.wmctrl}/bin/wmctrl -l | ${pkgs.gnugrep}/bin/grep "Mozilla Firefox$" | ${pkgs.gawk}/bin/awk  {' print $1 '} | ${pkgs.findutils}/bin/xargs -I{} ${pkgs.wmctrl}/bin/wmctrl -i -a {}
  '';

  g-help = pkgs.writeShellScriptBin "g-help" ''
    echo "Fx    -> Switch to WS x
    SHIFT Fx    -> Move to WS Fx
    SUPER Q     -> Close window
    SUPER T     -> Launch Terminator
    SUPER F     -> Launch Firefox
    SUPER B     -> Launch Nautilus
    SUPER R     -> Launcher
    SUPER G     -> Goto Window
    SUPER <-    -> Window half screen on left" |  ${pkgs.zenity}/bin/zenity --text-info --width=500 --height=400
  '';


  run = pkgs.writeShellScriptBin "run" ''
    PATH=/run/current-system/sw/bin/:$PATH
    if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
        ${pkgs.wofi}/bin/wofi --show drun
    elif [ "$XDG_SESSION_TYPE" = "x11" ]; then
        ${pkgs.rofi}/bin/rofi -show drun
    fi
  '';

  next-meeting =  pkgs.writeShellScriptBin "next-meeting" ''
    ${pkgs.khal}/bin/khal list today --json start-long --json title | ${pkgs.jq}/bin/jq -s --arg now "$(date '+%Y-%m-%d %H:%M')" '
      flatten
      | map(select(.["start-long"] >= $now))
      | sort_by(."start-long")
      | .[0]
      | "\(.["start-long"] | strptime("%Y-%m-%d %H:%M") | strftime("%d-%m %H:%M")) \(.title)"
    '
  '';


  clock = pkgs.writeShellScriptBin "clock" ''
    ${pkgs.zenity}/bin/zenity --info --text="$(date '+%H:%M:%S%n%A %d %B %Y')" --timeout=10
  '';


  obsidian-term = pkgs.writeShellScriptBin "obsidian-term" ''
    my_file=`${pkgs.findutils}/bin/find /data/Obsidian/mickael -name "*.md" | ${pkgs.fzf}/bin/fzf | xargs -d '\n'`
    myfile_name=`${pkgs.coreutils}/bin/basename "$my_file"`
    ${pkgs.tmux}/bin/tmux rename-window "Obsidian $myfile_name"
    nvim "$my_file"
  '';

  todo-term = pkgs.writeShellScriptBin "todo-term" ''
    ${pkgs.todoman}/bin/todo list --sort due
   read -n1
  '';

  clipboard-copy = pkgs.writeShellScriptBin "clipboard-copy" ''
    if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
      ${pkgs.wl-clipboard}/bin/wl-copy
    else
      ${pkgs.xclip}/bin/xclip -selection clipboard
    fi
  '';

  copyq-buff = pkgs.writeShellScriptBin "copyq-buff" ''
    count=$(copyq count)

    if [ "$count" -gt 100 ]; then
        count=100
    fi
    
    selected=$(seq 0 $((count - 1)) | while read i; do
        copyq read $i | tr '\n' '\u2029' | awk -v idx="$i" '{print idx ":" $0}'
    done | fzf --ansi --preview "echo {} | tr '\u2029' '\n'" --height 100%)
    
    if [ -n "$selected" ]; then
        index=$(echo "$selected" | cut -d':' -f1)
        copyq select $index
    fi
  '';



  my-news = pkgs.writeShellScriptBin "my-news" ''

    if [ -z "$1" ] || [ "$1" = "list" ]; then
        news-cli -list-unread -json | jq -r '.[] | "\(.feedName)\t\(.id)\t\(if (.title | length) > 80 then (.title[:77] + "...") else .title end)"' | fzf --delimiter='\t' --with-nth=1,3 --no-select-1 | cut -f2
    elif [ "$1" = "read" ]; then
        news_id=`news-cli -list-unread -json | jq -r '.[] | "\(.feedName)\t\(.id)\t\(if (.title | length) > 80 then (.title[:77] + "...") else .title end)"' | fzf --delimiter='\t' --with-nth=1,3 | cut -f2`
        news_url=`news-cli -get-url $news_id`
        firefox --new-window "$news_url"        
    elif [ "$1" = "readandmark" ]; then
        news_id=`news-cli -list-unread -json | jq -r '.[] | "\(.feedName)\t\(.id)\t\(if (.title | length) > 80 then (.title[:77] + "...") else .title end)"' | fzf --delimiter='\t' --with-nth=1,3 | cut -f2`
        news_url=`news-cli -get-url $news_id`
        firefox --new-window "$news_url"        
        news-cli -mark-read $news_id
    fi
  '';

  my-shortcut = pkgs.writeShellScriptBin "my-shortcut" ''
    command=`cat ~/.config/shortcut | ${pkgs.fzf}/bin/fzf --delimiter='|' --with-nth=2.. --prompt='Shortcut > ' | ${pkgs.gawk}/bin/awk -F'|' '{print $1}'`
    if [ -n "$command" ]; then
      eval "$command"
    fi
  '';


  tmux-windows = pkgs.writeShellScriptBin "tmux-windows" ''
    window=$(${pkgs.tmux}/bin/tmux list-windows -F '#I #W' | ${pkgs.fzf}/bin/fzf --prompt="tmux window > " | ${pkgs.gawk}/bin/awk '{print $1}')
    
    if [ -n "$window" ]; then
        ${pkgs.tmux}/bin/tmux select-window -t "$window"
    fi
  '';


  alarm = pkgs.buildGoModule rec {
    pname = "alarm";

    version = "1.5";

    src = pkgs.fetchFromGitHub {
      owner = "Mickael-Roger";
      repo = "alarm";
      rev = "v${version}";
      sha256 = "sha256-liBeO93BdedDQHGsYMiqFOdf8aXqtd80mOWaZrd5nnI=";
    };

    vendorHash = "sha256-koKCD0w2KZFfG8h33UzAIImOPl82xXgMo+bac9mNUSk=";

    subPackages = [ "." ];

  };

  mcp-freshrss = pkgs.buildGoModule rec {
    pname = "mcp-freshrss";

    version = "1.4";

    src = pkgs.fetchFromGitHub {
      owner = "Mickael-Roger";
      repo = "mcp-freshrss";
      rev = "v${version}";
      sha256 = "sha256-uLEMBdxB7eBMfHsFEpgd4KIgISTls+bmremh/XwekY0=";
    };

    vendorHash = "sha256-h7rWkCBOgmzR1NeC8H7kduwD10RpT6opRLcBRJPGBgk=";

    subPackages = [ "." ];

  };

  agentmemoryVersion = "0.9.20";
  agentmemoryOpencodeRev = "c2f231fe8bcf9b1fa296ad5ee81267eec94de768";
  agentmemoryOpencodeFile = path: hash: pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/rohitg00/agentmemory/${agentmemoryOpencodeRev}/${path}";
    inherit hash;
  };

  mcp-tasks = pkgs.buildGoModule rec {
    pname = "mcp-webdav-tasks";

    version = "0.1";

    src = pkgs.fetchFromGitHub {
      owner = "Mickael-Roger";
      repo = "mcp-webdav-tasks";
      rev = "v${version}";
      sha256 = "sha256-xf2kcfrUfSbzBwweKiqti+JJHyVM0YYk2t2hir25nI0=";
    };

    vendorHash = "sha256-Foyk/KOJQgredlbA1YG2k6k7YEILytTCdSwUrRnlnJg=";

    subPackages = [ "." ];

  };

  alarm-term-create = pkgs.writeShellScriptBin "alarm-term-create" ''
   ${alarm}/bin/alarm create
  '';

  alarm-term-ack = pkgs.writeShellScriptBin "alarm-term-ack" ''
   ${alarm}/bin/alarm ack 0
  '';

  cal-term = pkgs.writeShellScriptBin "cal-term" ''
   ${pkgs.khal}/bin/ikhal
  '';



  create-note = pkgs.writeShellScriptBin "create-note" ''
    day=`${pkgs.coreutils-full}/bin/date +'%Y-%m-%d'`
    touch /data/Obsidian/mickael/Inbox/$day.md
    nvim /data/Obsidian/mickael/Inbox/$day.md
  '';

in
{
  mickael = {
    home.stateVersion = "25.05";

    home.username = "mickael";
    home.homeDirectory = "/home/mickael"; 

    home.file."background" = {
      source = ./wallpapers/matrix.jpg;
    };

    xdg.configFile."khal/config".text = ''
      [calendars]

      [[famille]]
      path = /home/mickael/.local/share/vdirsyncer/calendars/Famille
      type = calendar
      
      [[perso]]
      path = /home/mickael/.local/share/vdirsyncer/calendars/Calendar
      type = calendar
      
      [locale]
      timeformat = %H:%M
      dateformat = %Y-%m-%d
      longdateformat = %Y-%m-%d
      datetimeformat = %Y-%m-%d %H:%M
      longdatetimeformat = %Y-%m-%d %H:%M
      
      [default]
      default_calendar = famille

    '';

    xdg.configFile."todoman/config.py".text = ''
      path = "~/.local/share/vdirsyncer/tasks/*"
      time_format = "%H:%M"
      date_format = "%Y-%m-%d"
      default_list = "Todo"
      default_due = 48
      
    '';

    xdg.configFile."shortcut".text = ''
      ${my-news}/bin/my-news list | News: List news
      ${my-news}/bin/my-news read | News: Open
      ${my-news}/bin/my-news readandmark | News: Open and mark it read
      ${ssh-connect}/bin/ssh-connect | SSH: Connect [Ctrl-b h]
      ${obsidian-term}/bin/obsidian-term | Obsidian: Open a note [Ctrl-b o]
      ${create-note}/bin/create-note | Obsidian: Create a note [Ctrl-b *]
      ${alarm}/bin/alarm create | Alarm: Create [Ctrl-b a]
      ${alarm}/bin/alarm list; read -n 1 -s | Alarm: list
      ${goto-window}/bin/goto-window | Windows: Goto an application window [Ctrl-b g]
      ${cal-term}/bin/cal-term | Calendar: Print calendar [Ctrl-b Ctrl-c]
      /var/run/current-system/sw/bin/ff | Firefox: Goto a tab [Ctrl-b f]
      ${copyq-buff}/bin/copyq-buff | Copyq: Select in buffer [Ctrl-b b]
      ${todo-term}/bin/todo-term | Todo: List Todo [Ctrl-b t]
    '';

    xdg.configFile."opencode/opencode.json".text = ''
      {
       "$schema": "https://opencode.ai/config.json",
       "formatter": true,
       "theme": "opencode",
       "plugin": ["opencode-gemini-auth@latest", "./plugins/agentmemory-capture.ts"],
       "autoupdate": false,
       "mcp": {
         "freecad": {
            "type": "local",
            "enabled": true,
            "command": ["uvx", "freecad-mcp"],
         },
          "brave-search": {
            "type": "local",
            "enabled": true,
            "command": ["npx", "-y", "@brave/brave-search-mcp-server", "--transport", "stdio"],
            "environment": {
              "BRAVE_API_KEY": "${secrets.brave_api_key}"
            }
          },
          "tasks": {
            "type": "local",
            "command": ["${mcp-tasks}/bin/mcp-webdav-tasks"],
            "enabled": true,
            "environment": {
              "MCP_WEBDAV_TASKS_SERVER": "https://zimbra1.mail.ovh.net/dav/${secrets.mail.username}/",
              "MCP_WEBDAV_TASKS_USERNAME": "${secrets.mail.username}",
              "MCP_WEBDAV_TASKS_PASSWORD": "${secrets.mail.password}",
            },
          },
          "context7": {
            "type": "remote",
            "url": "https://mcp.context7.com/mcp",
            "enabled": true,
            "headers": {
              "CONTEXT7_API_KEY": "${secrets.context7_api}"
            },
          },
          "n8n": {
            "type": "local",
            "command": ["n8n-mcp"],
            "enabled": true,
            "environment": {
              "MCP_MODE": "stdio",
              "LOG_LEVEL": "error",
              "DISABLE_CONSOLE_OUTPUT": "true",
              "N8N_API_URL": "${secrets.n8n.url}",
              "N8N_API_KEY": "${secrets.n8n.token}"
            }
          },
          "github": {
            "type": "local",
            "command": ["github-mcp-server", "stdio"],
            "enabled": true,
            "environment": {
              "GITHUB_PERSONAL_ACCESS_TOKEN": "${secrets.github_token}",
            }
          },
          "playwright": {
            "type": "local",
            "command": ["${pkgs.playwright-mcp}/bin/mcp-server-playwright"],
            "enabled": true
          },
          "memory": {
            "type": "local",
            "command": ["${pkgs.nodejs_20}/bin/npx", "-y", "@agentmemory/mcp@${agentmemoryVersion}"],
            "enabled": true,
            "environment": {
              "AGENTMEMORY_URL": "http://localhost:3111"
            }
          },
        },
        "tools": {
          "memory_memory_recall": true,
          "memory_memory_compress_file": true,
          "memory_memory_save": true,
          "memory_memory_patterns": false,
          "memory_memory_smart_search": true,
          "memory_memory_file_history": true,
          "memory_memory_sessions": true,
          "memory_memory_timeline": true,
          "memory_memory_profile": true,
          "memory_memory_export": false,
          "memory_memory_relations": true,
          
          "memory_memory_patterns": false,
          "memory_memory_timeline": true,
          "memory_memory_relations": true,
          "memory_memory_graph_query": true,
          "memory_memory_consolidate": false,
          "memory_memory_claude_bridge_sync": false,
          "memory_memory_team_share": false,
          "memory_memory_team_feed": false,
          "memory_memory_audit": false,
          "memory_memory_governance_delete": false,
          "memory_memory_snapshot_create": false,
          "memory_memory_action_create": true,
          "memory_memory_action_update": true,
          "memory_memory_frontier": false,
          "memory_memory_next": true,
          "memory_memory_lease": false,
          "memory_memory_routine_run": false,
          "memory_memory_signal_send": false,
          "memory_memory_signal_read": false,
          "memory_memory_checkpoint": false,
          "memory_memory_mesh_sync": false,
          "memory_memory_sentinel_create": false,
          "memory_memory_sentinel_trigger": false,
          "memory_memory_sketch_create": false,
          "memory_memory_sketch_promote": false,
          "memory_memory_crystallize": false,
          "memory_memory_diagnose": false,
          "memory_memory_heal": false,
          "memory_memory_facet_tag": false,
          "memory_memory_facet_query": false,
          "memory_memory_verify": false,
          "freecad_*": false,
          "n8n_*": false,
          "playwright_*": false,
          "github_*": false,
          "tasks_*": false,
          "brave-search_*": false,
          //Needs OPENCODE_ENABLE_EXA=1 env var
          "websearch": true
        },
        "agent": {
          "agent-builder": {
            "hidden": true
          },
          "freecad": {
            "permission": {
              "freecad_*": "allow",
            }
          },
          "build": {
            "permission": {
              "task": {
                "agent-*": "deny"
              }
            },
          },
          "planificator": {
            "permission": {
              "github_*": "allow",
              "playwright_*": "allow",
              "bash": "allow",
              "webfetch": "allow",
              "glob": "allow",
              "write": "deny",
              "edit": "deny",
              "lsp": "allow",
              "task": {
                "agent-*": "allow"
              }
            },
            "tools": {
              "goToDefinition": true,
              "findReferences": true,
              "hover": true,
              "documentSymbol": true,
              "workspaceSymbol": true,
              "goToImplementation": true,
              "prepareCallHierarchy": true,
              "incomingCalls": true,
              "outgoingCall": true
            }
          },
          "explore": {
            "permission": {
              "lsp": "allow",
              "task": {
                "agent-*": "deny"
              }
            },
            "tools": {
              "goToDefinition": true,
              "findReferences": true,
              "hover": true,
              "documentSymbol": true,
              "workspaceSymbol": true,
              "goToImplementation": true,
              "prepareCallHierarchy": true,
              "incomingCalls": true,
              "outgoingCall": true
            }
          },
          "review": {
            "permission": {
              "task": {
                "agent-*": "deny"
              }
            },
            "tools": {
              "github_*": true,
              "bash": true,
              "webfetch": true,
              "glob": true,
              "write": false,
              "edit": false
            }
          },
          "security-review": {
            "permission": {
              "task": {
                "agent-*": "deny"
              }
            },
            "tools": {
              "github_*": true,
              "bash": true,
              "webfetch": true,
              "glob": true,
              "write": false,
              "edit": false
            }
          },
          "git": {
            "permission": {
              "task": {
                "agent-*": "deny"
              }
            },
            "tools": {
              "github_*": true,
              "bash": true,
              "webfetch": true,
              "write": false,
              "edit": false
            }
          },
          "n8n": {
            "permission": {
              "task": {
                "agent-*": "deny"
              }
            },
            "tools": {
              "n8n_*": true,
              "bash": true,
              "webfetch": true,
              "write": true,
              "edit": true
            }
          },
          "webbrowser": {
            "permission": {
              "task": {
                "agent-*": "deny"
              }
            },
            "tools": {
              "playwright_*": true,
              "bash": true,
              "webfetch": true,
            }
          },
          "chat": {
            "permission": {
              "task": {
                "agent-*": "deny"
              }
            },
            "tools": {
              "tasks_*": true,
              "websearch_*": false,
              "brave-search_*": true,
              "bash": false,
              "grep": true,
              "webfetch": true,
              "write": true,
              "edit": false
            }
          },
          "memory": {
            "permission": {
              "task": {
                "agent-*": "deny"
              }
            },
            "tools": {
              "memory_memory_*": true,
              "websearch_*": true,
              "bash": false,
              "grep": true,
              "webfetch": true,
              "write": true,
              "edit": false
            }
          },
        },
        "lsp": {
          "pyright": {
            "command": ["${pkgs.pyright}/bin/pyright-langserver", "--stdio"]
          },
          "gopls": {
            "command": ["${pkgs.gopls}/bin/gopls"]
          },
          "typescript": {
            "command": ["${pkgs.typescript-language-server}/bin/typescript-language-server"]
          },
          "bash": {
            "command": ["${pkgs.bash-language-server}/bin/bash-language-server"]
          },
          "clangd": {
            "command": ["${pkgs.clang-tools}/bin/clangd"]
          },
          "nixd": {
            "command": ["${pkgs.nixd}/bin/nixd"]
          },
          "yaml-ls": {
            "command": ["${pkgs.yaml-language-server}/bin/yaml-language-server", "--stdio"]
          },
          "openscad-lsp": {
            "command": ["${pkgs.openscad-lsp}/bin/openscad-lsp", "--stdio"],
            "extensions": [".scad"]
          }
        }
      }
    '';

    xdg.configFile."opencode/AGENTS.md".text = builtins.readFile ./config-files/opencode/AGENTS.md;
    xdg.configFile."opencode/agent/review.md".text =  builtins.readFile ./config-files/opencode/agent/review.md;
    xdg.configFile."opencode/agent/security-review.md".text =  builtins.readFile ./config-files/opencode/agent/security-review.md;
    xdg.configFile."opencode/agent/test.md".text =  builtins.readFile ./config-files/opencode/agent/test.md;
    xdg.configFile."opencode/agent/git.md".text =  builtins.readFile ./config-files/opencode/agent/git.md;
    xdg.configFile."opencode/agent/n8n.md".text =  builtins.readFile ./config-files/opencode/agent/n8n.md;
    xdg.configFile."opencode/agent/chat.md".text =  builtins.readFile ./config-files/opencode/agent/chat.md;
    xdg.configFile."opencode/agent/webbrowser.md".text =  builtins.readFile ./config-files/opencode/agent/webbrowser.md;
    xdg.configFile."opencode/agent/planificator.md".text =  builtins.readFile ./config-files/opencode/agent/planificator.md;
    xdg.configFile."opencode/agent/slop-remover.md".text =  builtins.readFile ./config-files/opencode/agent/slop-remover.md;
    xdg.configFile."opencode/agent/agent-builder.md".text =  builtins.readFile ./config-files/opencode/agent/agent-builder.md;
    xdg.configFile."opencode/agent/freecad.md".text =  builtins.readFile ./config-files/opencode/agent/freecad.md;
    xdg.configFile."opencode/agent/memory.md".text =  builtins.readFile ./config-files/opencode/agent/memory.md;
    xdg.configFile."opencode/commands/archive.md".text =  builtins.readFile ./config-files/opencode/commands/archive.md;
    xdg.configFile."opencode/commands/gitmerge.md".text =  builtins.readFile ./config-files/opencode/commands/gitmerge.md;
    xdg.configFile."opencode/plugins/agentmemory-capture.ts".source = agentmemoryOpencodeFile "plugin/opencode/agentmemory-capture.ts" "sha256-VsnrsNxDLtkv5nlHIkOj/qw43VGYdwCyo9VOTDJiUxI=";
    xdg.configFile."opencode/commands/recall.md".source = agentmemoryOpencodeFile "plugin/opencode/commands/recall.md" "sha256-OwVwHbreZeEZJyZZK5Ivqs4mvwtlnzHntUpqWEiA6Xs=";
    xdg.configFile."opencode/commands/remember.md".source = agentmemoryOpencodeFile "plugin/opencode/commands/remember.md" "sha256-jifK8lui0vH9eUTwRUyQz5tLX/JAVKkcW66yQgJfpqk=";
    #xdg.configFile."opencode/commands/memory.md".text =  builtins.readFile ./config-files/opencode/commands/memory.md;
    #xdg.configFile."opencode/plugins/anthropic-prompt.txt".text =  builtins.readFile ./config-files/opencode/plugins/anthropic-prompt.txt;

    systemd.user.services.agentmemory = {
      Unit = {
        Description = "agentmemory server";
        After = [ "network-online.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.nodejs_20}/bin/npx -y @agentmemory/agentmemory@${agentmemoryVersion}";
        Restart = "on-failure";
        RestartSec = 5;
        Environment = [
          # Auth and endpoint
          "AGENTMEMORY_URL=http://localhost:3111"
          "AGENTMEMORY_VIEWER_URL=http://localhost:3113"
          # MCP/runtime
          "AGENTMEMORY_TOOLS=all"
          # Behaviour flags
          "AGENTMEMORY_AUTO_COMPRESS=true"
          #"AGENTMEMORY_INJECT_CONTEXT=true"
          "CONSOLIDATION_ENABLED=true"
          "CONSOLIDATION_DECAY_DAYS=30"
          "GRAPH_EXTRACTION_ENABLED=true"
          #"GRAPH_EXTRACTION_BATCH_SIZE=8"
          #"AGENTMEMORY_REFLECT=false"
          #"AGENTMEMORY_DROP_STALE_INDEX=false"
          #"AGENTMEMORY_IMAGE_EMBEDDINGS=false"
          # Embeddings
          "EMBEDDING_PROVIDER=openai"
          "OPENAI_API_KEY=${secrets.litellm_token}"
          "OPENAI_BASE_URL=https://server.taila2494.ts.net/"
          "OPENAI_MODEL=glm-4.5"
          "OPENAI_API_KEY_FOR_LLM=true"
          "OPENAI_EMBEDDING_MODEL=text-embedding-3-small"
          #"OPENAI_EMBEDDING_DIMENSIONS=1536"
          # LLM provider, optional
          # "ANTHROPIC_API_KEY=${secrets.anthropic_api_key}"
          # "ANTHROPIC_MODEL=claude-sonnet-4-20250514"
          # "ANTHROPIC_BASE_URL=https://api.anthropic.com"
          # "GEMINI_API_KEY=${secrets.gemini_api_key}"
          # "GEMINI_MODEL=gemini-2.5-flash"
          # "OPENROUTER_API_KEY=${secrets.openrouter_api_key}"
          # "OPENROUTER_MODEL=anthropic/claude-sonnet-4-20250514"
          # "MINIMAX_API_KEY=${secrets.minimax_api_key}"
          # "MINIMAX_MODEL=MiniMax-M2.7"
          "MAX_TOKENS=4096"
          "AGENTMEMORY_LLM_TIMEOUT_MS=60000"
          "AGENTMEMORY_ALLOW_AGENT_SDK=false"
          # Snapshots/export
          "SNAPSHOT_ENABLED=false"
          "SNAPSHOT_DIR=/home/mickael/.agentmemory/snapshots"
          "SNAPSHOT_INTERVAL=3600"
          "USER_ID=mickael"
          "OBSIDIAN_AUTO_EXPORT=true"
          "AGENTMEMORY_EXPORT_ROOT=/data/Obsidian/mickael/Logger/agentmemory/"
          # Debug
          "AGENTMEMORY_DEBUG=0"
        ];
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };


    dconf.settings = {

      "org/gnome/desktop/wm/keybindings" = {
        switch-to-workspace-1 = ["F1"];
        switch-to-workspace-2 = ["F2"];
        switch-to-workspace-3 = ["F3"];
        switch-to-workspace-4 = ["F4"];
        switch-to-workspace-5 = ["F5"];
        switch-to-workspace-6 = ["F6"];
        switch-to-workspace-7 = ["F7"];
        switch-to-workspace-8 = ["F8"];
        switch-to-workspace-9 = ["F9"];
        switch-to-workspace-10 = ["F10"];
        move-to-workspace-1 = ["<Shift>F1"];
        move-to-workspace-2 = ["<Shift>F2"];
        move-to-workspace-3 = ["<Shift>F3"];
        move-to-workspace-4 = ["<Shift>F4"];
        move-to-workspace-5 = ["<Shift>F5"];
        move-to-workspace-6 = ["<Shift>F6"];
        move-to-workspace-7 = ["<Shift>F7"];
        move-to-workspace-8 = ["<Shift>F8"];
        move-to-workspace-9 = ["<Shift>F9"];
        move-to-workspace-10 = ["<Shift>F10"];
        close = ["<Super>q"];
      };

      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/terminator/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/firefox/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/nautilus/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/run/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/help/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/goto/"
        ];
      };
  
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/help" = {
        name = "Help";
        command = "${g-help}/bin/g-help";
        binding = "<Super>h";
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/terminator" = {
        name = "Terminator";
        command = "${pkgs.terminator}/bin/terminator";
        binding = "<Super>t";
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/firefox" = {
        name = "Firefox";
        #command = "${pkgs.firefox}/bin/firefox --marionette";
        command = "${pkgs.firefox}/bin/firefox";
        binding = "<Super>f";
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/nautilus" = {
        name = "Nautilus";
        command = "${pkgs.nautilus}/bin/nautilus";
        binding = "<Super>b";
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/run" = {
        name = "Run";
        command = "${run}/bin/run";
        binding = "<Super>r";
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/goto" = {
        name = "Goto";
        command = "${pkgs.rofi}/bin/rofi -show window";
        binding = "<Super>g";
      };


      "org/gnome/desktop/background" = {
        color-shading-type = "solid";
        picture-options = "zoom";
        picture-uri = "file:///home/mickael/background";
        show-desktop-icons = true;
      }; 
      "org/gnome/mutter" = {
        check-alive-timeout = 60000;
        dynamic-workspaces = false;
      };
      "org/gnome/desktop/interface" = {
        clock-show-seconds = true;
        clock-show-weekday = true;
      };
      "org/gnome/desktop/wm/preferences" = {
        num-workspaces = 10;
        button-layout = "menu:minimize,maximize,spacer,close";
      };
      "org/gnome/shell" = {
        disable-user-extensions = false;
        window-switcher = "both";
	disabled-extensions = [ ];
	enabled-extensions = [
          "apps-menu@gnome-shell-extensions.gcampax.github.com"
          "printers@linux-man.org"
          "drive-menu@gnome-shell-extensions.gcampax.github.com"
          "screenshot-window-sizer@gnome-shell-extensions.gcampax.github.com"
          #"dash-to-dock@micxgx.gmail.com"
          "workspace-indicator@gnome-shell-extensions.gcampax.github.com"
          "user-theme@gnome-shell-extensions.gcampax.github.com"
      	];
        #favorite-apps = [
        #  "firefox.desktop"
        #  "anki.desktop"
        #  "obsidian.desktop"
        #  "mykeepass.desktop"
        #  "discord.desktop"
        #  "terminator.desktop"
        #  "org.gnome.Console.desktop"
        #  "virt-manager.desktop"
        #  "weechat.desktop"
        #  "gedit.desktop"
        #  "org.gnome.gitlab.cheywood.Iotas.desktop"
        #  "thunderbird.desktop"
        #  "dev.geopjr.Tuba.desktop"
        #  "org.gnome.Nautilus.desktop"
        #  "io.gitlab.news_flash.NewsFlash.desktop"
        #  "org.freecad.FreeCAD.desktop"
        #  "freetube.desktop"
        #];
      };
      "org/gnome/shell/extensions/printers" = {
        connect-to = "Gnome Control Center";
        show-icon = "Always";
        show-error = true;
        show-jobs = true;
      };
      "org/gnome/shell/extensions/dash-to-dock" = {
        dock-position = "LEFT";
        activate-single-window = true;
        show-windows-preview = true;
        dock-fixed = true;
      };
     };

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;


    xdg.desktopEntries = {
      mykeepass = {
        name = "Keepass";
        genericName = "Keepass mickael";
        exec = "keepass /home/mickael/Documents/password_database.kdbx";
        icon = "${pkgs.keepass}/share/icons/hicolor/64x64/apps/keepass.png";
        terminal = false;
        categories = [ "Application" ];
      };
    };

    xdg.enable = true;
    xdg.configFile."weechat/irc.conf" = {
      source = ./config-files/weechat/irc.conf;
    };

    wayland.windowManager.sway = {
      enable = true;
      extraConfig = ''
        input "type:keyboard" {
          xkb_layout fr
        }
      '';
    };


    xdg.configFile."cosmic/com.system76.CosmicSettings.Wallpaper/v1/custom-images".text = ''
      [
        "/home/mickael/background",
      ]
    '';

    xdg.configFile."cosmic/com.system76.CosmicPanel/v1/entries".text = ''
      [
        "Panel",
      ]
    '';

    xdg.configFile."cosmic/com.system76.CosmicSettings.Shortcuts/v1/custom".text = ''
      {
        (modifiers: [ Super, ], key: "Left", ): Move(Left),
        (modifiers: [ Super, ], key: "Right", ): Move(Right),
        (modifiers: [ Super, ], key: "Up", ): Move(Up),
        (modifiers: [ Super, ], key: "Down", ): Move(Down),

        (modifiers: [ Super, Ctrl, ], key: "Right", ): MoveToNextWorkspace,
        (modifiers: [ Super, Ctrl, ], key: "Left", ): MoveToPrevWorkspace,
  
        (modifiers: [ Super, ], key: "r", description: Some("Rofi"), ): Spawn("rofi -show drun"),
  
        (modifiers: [ Super, ], key: "h", description: Some("Help"), ): Spawn("${g-help}/bin/g-help"),

        (modifiers: [ Super, ], key: "t", description: Some("Terminator"), ): Spawn("${pkgs.terminator}/bin/terminator"),

        (modifiers: [ Super, ], key: "f", description: Some("Firefox"), ): Spawn("${pkgs.firefox}/bin/firefox"),

        (modifiers: [ Super, ], key: "b", description: Some("Browse"), ): Spawn("${pkgs.cosmic-files}/bin/cosmic-files"),

        (modifiers: [ Super, ], key: "g", description: Some("Goto"), ): Spawn("${pkgs.cosmic-launcher}/bin/cosmic-launcher"),

      }
    '';

    programs.rofi.enable = true;
    programs.rofi.package = pkgs.rofi;



    programs.git = {
      enable = true;
      lfs.enable = true;
      settings = {
        user.name  = "MickaelRoger";
        user.email = "mickael@mickael-roger.com";

        core = {
          editor = "vim";
          askPass = "";
        };
        http = {
          postBuffer = "52428800";
        };
        "credential \"https://github.com\"" = {
          username = "Mickael-Roger";
        };
      };
    };

    programs.vim = {
      enable = true;
      plugins = with pkgs.vimPlugins; [
        vim-addon-nix
        vim-nix
        nerdtree
        nerdtree-git-plugin
        vim-airline
        vim-go
        vim-plug
        goyo-vim
        markdown-preview-nvim
      ];
      settings = {
        ignorecase = true;
        number = true;
        copyindent = true;
      };
      extraConfig = ''
        syntax on
        set showmatch
        set mouse=n
         
        autocmd StdinReadPre * let s:std_in=1
        autocmd VimEnter * NERDTree | if argc() > 0 || exists("s:std_in") | wincmd p | endif
        autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif
    
        autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
        au BufNewFile,BufRead *.yaml,*.yml so ~/.vim/yaml.vim
    
      '';
    };

    programs.firefox = {
      enable = true;
      policies = {
        DisableTelemetry = true;
        DisableFirefoxStudies = true;

       ExtensionSettings = {
          "dotgit@davtur19" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/dotgit/latest.xpi";
            installation_mode = "force_installed";
          };
          "abp" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/adblock_plus/latest.xpi";
            installation_mode = "force_installed";
          };
          # Obsidian Web clipper
          "reload-motive-haunt-turf5-excu" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/file/4097921/reload_motive_haunt_turf5_excu-1.2.0.xpi";
            installation_mode = "force_installed";
	  };
          # Tab search
          "tabsearch" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/tab_search/latest.xpi";
            installation_mode = "force_installed";
          };
        };
      };

      profiles = {
        mickael = {
          isDefault = true;
         
          extensions = with nur.repos.rycee.firefox-addons; [
                adblocker-ultimate
                privacy-badger
                clearurls
                floccus
                startpage-private-search 
                privacy-redirect
                passbolt
           ];
        };       
      };     

    };



    programs.bash = {
      enable= true;
      
      initExtra = ''
        parse_git_branch() {
          git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
        }
        export PS1="\[$(tput setaf 77)\][\u\[$(tput setaf 171)\]@\h \[$(tput setaf 39)\]\w\[$(tput sgr0)\]\[\033[32m\]\[\033[33m\]\$(parse_git_branch)\[\033[00m\]\[$(tput setaf 77)\]]\[$(tput sgr0)\]$ "
        
        export OPENCODE_ENABLE_EXA=1
        export OPENCODE_EXPERIMENTAL_LSP_TOOL=true
        export OPENCODE_ARCHIVER_DIRECTORY="/data/Obsidian/mickael/Logger/Opencode/"

        export QT_QPA_PLATFORM=wayland
      ''; 
    
      shellAliases = {
        k = "${pkgs.kubectl}/bin/kubectl";
        vi = "nvim";
      };
  
    }; 

    systemd.user.services."tmux-save" = {
      Service = {
        Type = "oneshot";
        Environment = "SCRIPT_OUTPUT=quiet";
        ExecStart = "${pkgs.tmuxPlugins.resurrect}/share/tmux-plugins/resurrect/scripts/save.sh";
      };
    };

    systemd.user.timers."tmux-save" = {
      Unit = {
        Description = "Save tmux";
      };
      Timer = {
        OnBootSec = "5min";
        OnUnitActiveSec = "6h";
        Unit = "tmux-save.service";
      };
      Install = {
        WantedBy = [ "timers.target" ];
      };
    };

    programs.tmux = {
      enable = true;
      terminal = "tmux-256color";
      mouse = true;
      clock24 = true;
      escapeTime = 100;
      plugins = with pkgs.tmuxPlugins; [
        resurrect
        #continuum
      ];
      extraConfig = ''

#run-shell ${pkgs.tmuxPlugins.resurrect}/share/tmux-plugins/resurrect/scripts/restore.sh

set -g @plugin 'tmux-plugins/tmux-yank'
set -g @yank_with_mouse on
set -g @yank_selection 'primary'
setw -g mode-keys vi
bind-key -T copy-mode-vi MouseDragEnd1Pane send -X copy-pipe-and-cancel "${clipboard-copy}/bin/clipboard-copy"
set -g status-style fg=white,bg=black
set -g status-right '#[fg=green] #(${next-meeting}/bin/next-meeting)  #[fg=white] #(${alarm}/bin/alarm get --tmux)   #[fg=orange] %d.%m.%Y #[fg=pink]%H:%M:%S'
set -g status-interval 2
set -g status-left "#(tmux-mem-cpu-load -a 0 --interval 1) #[fg=blue] 󱂬 #(tmux display-message -p '#{window_name}')"
set -g status-left-length 120
set -g status-right-length 120
set-option -g repeat-time 300
set -g window-status-format ""
set -g window-status-current-format ""
bind h new-window -n "tmp-ssh" '${ssh-connect}/bin/ssh-connect' C-m
bind o new-window -n "tmp-obsidian" '${obsidian-term}/bin/obsidian-term' C-m
bind a new-window -n 'tmp-alarm' '${alarm-term-create}/bin/alarm-term-create' C-m
bind C-a new-window -n 'tmp-alarm' '${alarm-term-ack}/bin/alarm-term-ack' C-m
bind * new-window -n "tmp-note" '${create-note}/bin/create-note' C-m
bind g new-window -n "tmp-goto" '${goto-window}/bin/goto-window' C-m
bind C-c run-shell "tmux display-popup -E -h 70% -w 70% -T 'Calendar' '${cal-term}/bin/cal-term'" 
bind s run-shell "tmux display-popup -E -h 70% -w 70% -T 'Shortcut' '${my-shortcut}/bin/my-shortcut'" 
bind b run-shell "tmux display-popup -E -h 70% -w 70% -T 'Copyq' '${copyq-buff}/bin/copyq-buff'" 
bind w run-shell "tmux display-popup -E -h 70% -w 70% -T 'Windows' '${tmux-windows}/bin/tmux-windows'"
bind t run-shell "tmux display-popup -E -h 70% -w 70% -T 'Todo' '${todo-term}/bin/todo-term'" 
bind f new-window -n "tmp-ff" '${goto-ff}/bin/goto-ff' C-m
bind -n S-PageUp copy-mode \; send-keys PageUp
bind -n S-PageDown send-keys PageDown
bind-key -T copy-mode-vi v send -X begin-selection
bind-key -T copy-mode-vi y send -X copy-pipe-and-cancel "${clipboard-copy}/bin/clipboard-copy"
bind-key -T copy-mode-vi Enter send -X copy-pipe-and-cancel "${clipboard-copy}/bin/clipboard-copy"
set -g @resurrect-capture-pane-contents 'on'
set -g @resurrect-save-shell-history 'on'
setw -g window-style 'fg=default,bg=colour234'
setw -g window-active-style 'fg=default,bg=default'
bind-key 4 new-window \; split-window -h \; split-window -v \; select-pane -t 0 \; split-window -v \; select-layout tiled
bind-key 6 new-window \; split-window -h -l '67%' \; split-window -h -l '50%' \; select-pane -t 0 \; split-window -v \; select-pane -t 2 \; split-window -v \; select-pane -t 4 \; split-window -v

      '';
      historyLimit = 100000;
    };

    programs.terminator = {
      enable = true;
      config = {
        global_config.enabled_plugins = "Logger,";
        profiles.default.show_titlebar = "False";
        profiles.default.scrollback_infinite = "True";
        profiles.default.scrollbar_position = "disabled";
      };
    };

    programs.chromium = {
      enable = true;
      package = pkgs.google-chrome;
      extensions = [
           { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # ublock origin
           { id = "baahncfnjojaofhdmdfkpeadigoemkif"; } # Voicewave chatgpt
           { id = "ameajnciachbdcneinbgnehihjolepkd"; } # Voicewave bard
        ];
    };       


    home.sessionVariables = {
      CODESTRAL_API_KEY = "${secrets.codestral_api}";
      NIXPKGS_ALLOW_UNFREE = 1;
      EDITOR = "nvim";
    };
    programs.neovim = {
  
      enable = true;
 
#      coc.enable = true;

      plugins = with pkgs.vimPlugins; [
        lazy-nvim 
        clangd_extensions-nvim
        nvim-lspconfig 
	nvchad
      ];

      extraLuaConfig = builtins.readFile ./config-files/nvim/init.lua;
  
    };

    services.copyq.enable = true;

  };
}
