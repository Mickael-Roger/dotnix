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
        echo "Connect to $SELECTED_HOST ..."
        ssh "$SELECTED_HOST"
    fi
  '';


  goto-window = pkgs.writeShellScriptBin "goto-window" ''
    ${pkgs.wmctrl}/bin/wmctrl -l | ${pkgs.gawk}/bin/awk '{printf $1" "; for(i=4;i<=NF;i++) printf $i" "; print ""}' | ${pkgs.fzf}/bin/fzf  --delimiter=' ' --with-nth=2.. | ${pkgs.gawk}/bin/awk '{print $1}' | ${pkgs.findutils}/bin/xargs -I{} ${pkgs.wmctrl}/bin/wmctrl -i -a {}
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

  ff-api-extension-xpi = pkgs.fetchurl {
    url = "https://github.com/Mickael-Roger/firefox-api-extension/releases/download/v1.0.19/firefox-api-extension-v1.0.19.xpi";
    sha256 = "sha256-RLAXf4UGTXmiynYECvHB5cPiFokasqHERFk2HIglSEQ=";
  };

  ff-api-extension = pkgs.runCommand "firefox-api-extension" {} ''
    mkdir -p $out
    cp ${ff-api-extension-xpi} $out/firefox-api-extension@famille-roger.com.xpi
  '';


  firefox-api-extension = pkgs.fetchFromGitHub {
      owner = "Mickael-Roger";
      repo = "firefox-api-extension";
      rev = "v1.0.21";
      sha256 = "sha256-a2vhpSgAcm9WGmowV5RMafk65J11P6VjS0iIMP93Y4k=";
    };


  clock = pkgs.writeShellScriptBin "clock" ''
    ${pkgs.zenity}/bin/zenity --info --text="$(date '+%H:%M:%S%n%A %d %B %Y')" --timeout=10
  '';


  obsidian-term = pkgs.writeShellScriptBin "obsidian-term" ''
    ${pkgs.findutils}/bin/find /data/Obsidian/mickael -name "*.md" | ${pkgs.fzf}/bin/fzf | xargs -d '\n' nvim
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
    command=`cat ~/.config/shortcut | ${pkgs.fzf}/bin/fzf --delimiter='|' --with-nth=2.. --prompt='Shortcut > ' | awk -F'|' '{print $1}'`
    if [ -n "$command" ]; then
      eval "$command"
    fi
  '';


  alarm = pkgs.buildGoModule rec {
    pname = "alarm";

    version = "1.4";

    src = pkgs.fetchFromGitHub {
      owner = "Mickael-Roger";
      repo = "alarm";
      rev = "v${version}";
      sha256 = "sha256-gMkECL9sl7W7GbfdU4TA+jMpykPXtYOTI7aYh/7yDMU=";
    };

    vendorHash = "sha256-koKCD0w2KZFfG8h33UzAIImOPl82xXgMo+bac9mNUSk=";

    subPackages = [ "." ];

  };

  alarm-term-create = pkgs.writeShellScriptBin "alarm-term-create" ''
   ${alarm}/bin/alarm create
  '';

  alarm-term-ack = pkgs.writeShellScriptBin "alarm-term-ack" ''
   ${alarm}/bin/alarm ack 0
  '';

  cal-term = pkgs.writeShellScriptBin "cal-term" ''
   ${pkgs.util-linux}/bin/cal -y
   read -n 1 -s
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
    '';


    xdg.configFile."opencode/opencode.json".text = ''
      {
        "$schema": "https://opencode.ai/config.json",
        "theme": "opencode",
        "autoupdate": false,
        "mcp": {
          "context7": {
            "type": "remote",
            "url": "https://mcp.context7.com/mcp",
            "enabled": true
          },
          "n8n-mcp": {
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
          }
        },
        "lsp": {
          "pyright": {
            "command": ["${pkgs.pyright}/bin/pyright-langserver", "--stdio"]
          },
          "gopls": {
            "command": ["${pkgs.gopls}/bin/gopls"]
          }
        }
      }
    '';

    xdg.configFile."opencode/AGENTS.md".text = ''
# Global Agent Guidelines

This file (`AGENTS.md`) defines global rules and best practices for all projects. If a local `AGENTS.md` does not exist or is empty, create one based on the project's content and these guidelines.

---

## 1. Language and Documentation Standards
- **Always use English** for:
  - `README.md` and all markdown files
  - Code comments
  - Variable, function, and file names
  - Any project-related documentation

---

## 2. Local `AGENTS.md` Management
- **After any action** that modifies code or local files:
  - Update the local `AGENTS.md` if the change is relevant to the project (e.g., new features, bug fixes, configuration changes).
  - Ensure all relevant information is recorded in `AGENTS.md`.

---

## 3. File Organization
- **If `AGENTS.md` becomes too large** or its content can be logically split:
  - Split it into dedicated markdown files (e.g., `CODING_STYLE.md`, `SETUP.md`, `DEPENDENCIES.md`).
  - Reference these files in the main `AGENTS.md` under clear sections, e.g.:
    ```markdown
    ## Coding Style
    See [CODING_STYLE.md](CODING_STYLE.md) for detailed guidelines.
    ```

---

## 4. Error Handling and Learning
- **When a user points out an error or suboptimal action**:
  - If the issue is relevant and likely to recur, document it in:
    - The local `AGENTS.md` (if not split)
    - The appropriate dedicated file (if split, e.g., `PITFALLS.md` or `LESSONS_LEARNED.md`)
  - Include:
    - A description of the issue
    - The correct approach or solution
    - Any context or examples to avoid repetition

---

## 5. Example Structure for Local `AGENTS.md`
```markdown
# Project-Specific Agent Guidelines

## Overview
- Purpose: [Brief description]
- Key files: [List and describe]

## Rules
- [Project-specific rules]

## Lessons Learned
- [Documented mistakes/improvements]

## See Also
- [CODING_STYLE.md](CODING_STYLE.md)
- [SETUP.md](SETUP.md)
    '';

    xdg.configFile."opencode/agent/review.md".text = ''
---
description: Reviews code for quality, security and best practices
mode: subagent
tools:
  write: false
  edit: false
---

You are in code review mode. Focus on:

- Code quality and best practices
- Potential bugs and edge cases
- Performance implications
- Security considerations

Provide constructive feedback without making direct changes.
    '';

    xdg.configFile."opencode/agent/test.md".text = ''
---
description: Writes and executes tests
mode: subagent
---

You are in **test engineering mode**. Your tasks are:

### 1. **Test Writing**
- Write **unit tests**, **integration tests**, and **end-to-end tests** as needed.
- Ensure tests are **clear**, **isolated**, and **maintainable**.
- Use the project's testing framework (e.g., pytest, Jest, RSpec).
- Cover edge cases, error handling, and typical usage scenarios.

### 2. **Test Execution**
- Run tests locally using the appropriate commands (e.g., `pytest`, `npm test`).
- Analyze test results and report:
  - Pass/fail status
  - Code coverage (if available)
  - Performance bottlenecks (if relevant)

### 3. **Test Maintenance**
- Update tests when the codebase changes.
- Refactor tests to avoid duplication and improve readability.
- Ensure tests are **deterministic** and **fast**.

### 4. **Guidelines**
- **Prioritize test coverage** for critical paths.
- **Document test assumptions** in comments or a `TESTING.md` file.
- **Fail fast**: If a test fails, provide actionable feedback.

### 5. **Output Format**
- Summarize test results in a clear format:
  ```markdown
  ## Test Results
  - **Status**: [Pass/Fail]
  - **Coverage**: [X%]
  - **Failures**: [List of failed tests with context]
  - **Suggestions**: [Improvements or additional tests needed]
    '';

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
      };

      "org/gnome/desktop/wm/keybindings" = {
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
      };

      "org/gnome/desktop/wm/preferences" = {
        num-workspaces = 10;
      };

      "org/gnome/desktop/wm/keybindings" = {
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

    xdg = {
      enable = true;
      configFile."weechat/irc.conf" = {
        source = ./config-files/weechat/irc.conf;
      };
    }; 

    wayland.windowManager.sway = {
      enable = true;
      extraConfig = ''
        input "type:keyboard" {
          xkb_layout fr
        }
      '';
    };


    xdg.configFile."cosmic/settings.ron".text = ''
      {
        panel: {
          enabled: false
        }
      }
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
      userName  = "MickaelRoger";
      userEmail = "mickael@mickael-roger.com";
      lfs.enable = true;
      extraConfig = {
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

    home.file.".mozilla/native-messaging-hosts/firefox_api_extension.json".text = ''
      {
        "name": "firefox_api_extension",
        "description": "Native host for Firefox REST API",
        "path": "${firefox-api-extension}/native/native_host.js",
        "type": "stdio",
        "allowed_extensions": ["ff-api-extension@famille-roger.com"]
      }
    '';

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
                ff-api-extension
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
        OnUnitActiveSec = "5min";
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

run-shell ${pkgs.tmuxPlugins.resurrect}/share/tmux-plugins/resurrect/scripts/restore.sh

set -g @plugin 'tmux-plugins/tmux-yank'
set -g @yank_with_mouse on
set -g @yank_selection 'primary'
setw -g mode-keys vi
bind-key -T copy-mode-vi MouseDragEnd1Pane send -X copy-pipe-and-cancel "${clipboard-copy}/bin/clipboard-copy"
set -g status-style fg=white,bg=black
set -g status-right '#(${alarm}/bin/alarm get --tmux)     #[fg=orange] %d.%m.%Y #[fg=pink] %H:%M:%S'
set -g status-interval 2
set -g status-left "#(tmux-mem-cpu-load -a 0 --interval 1)  󱂬  "
set -g status-left-length 120
set -g status-right-length 120
set-option -g repeat-time 300
bind h new-window -n "tmp-ssh" '${ssh-connect}/bin/ssh-connect' C-m
bind o new-window -n "tmp-obsidian" '${obsidian-term}/bin/obsidian-term' C-m
bind a new-window -n 'tmp-alarm' '${alarm-term-create}/bin/alarm-term-create' C-m
bind C-a new-window -n 'tmp-alarm' '${alarm-term-ack}/bin/alarm-term-ack' C-m
bind * new-window -n "tmp-note" '${create-note}/bin/create-note' C-m
bind g new-window -n "tmp-goto" '${goto-window}/bin/goto-window' C-m
bind C-c new-window -n "tmp-cal" '${cal-term}/bin/cal-term' C-m
bind s run-shell "tmux display-popup -E -h 70% -w 70% -T 'Shortcut' '${my-shortcut}/bin/my-shortcut'" C-m
bind b run-shell "tmux display-popup -E -h 70% -w 70% -T 'Copyq' '${copyq-buff}/bin/copyq-buff'" C-m
bind f new-window -n "tmp-ff" '/var/run/current-system/sw/bin/ff' C-m
bind -n S-PageUp copy-mode \; send-keys PageUp
bind -n S-PageDown send-keys PageDown
bind-key -T copy-mode-vi v send -X begin-selection
bind-key -T copy-mode-vi y send -X copy-pipe-and-cancel "${clipboard-copy}/bin/clipboard-copy"
bind-key -T copy-mode-vi Enter send -X copy-pipe-and-cancel "${clipboard-copy}/bin/clipboard-copy"
set -g @resurrect-capture-pane-contents 'on'
set -g @resurrect-save-shell-history 'on'
setw -g window-style 'fg=default,bg=colour234'
setw -g window-active-style 'fg=default,bg=default'

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

      extraLuaConfig = builtins.readFile  ./config-files/nvim/init.lua;
  
    };

    services.copyq.enable = true;

  };
}
