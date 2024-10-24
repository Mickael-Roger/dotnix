{ pkgs, nur, ... }:
{
  mickael = {
    home.stateVersion = "24.05";

    home.username = "mickael";
    home.homeDirectory = "/home/mickael"; 

    home.file."background" = {
      source = ./wallpapers/anonymous.jpg;
    };

    dconf.settings = {
      "org/gnome/desktop/background" = {
        color-shading-type = "solid";
        picture-options = "zoom";
        picture-uri = "file:///home/mickael/background";
        show-desktop-icons = true;
      }; 
      "org/gnome/desktop/interface" = {
        clock-show-seconds = true;
        clock-show-weekday = true;
      };
      "org/gnome/gitlab/cheywood/Iotas" = {
        nextcloud-endpoint = "https://nextcloud.taila2494.ts.net";
        nextcloud-username = "mickael";
        backup-note-extension = "md";
        index-category-style = "blue";
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
          "dash-to-dock@micxgx.gmail.com"
          "workspace-indicator@gnome-shell-extensions.gcampax.github.com"
          "user-theme@gnome-shell-extensions.gcampax.github.com"
      	];
        favorite-apps = [
          "firefox.desktop"
          "anki.desktop"
          "obsidian.desktop"
          "mykeepass.desktop"
          "discord.desktop"
          "org.gnome.Console.desktop"
          "virt-manager.desktop"
          "weechat.desktop"
          "gedit.desktop"
          "org.gnome.gitlab.cheywood.Iotas.desktop"
          "thunderbird.desktop"
          "dev.geopjr.Tuba.desktop"
          "org.gnome.Nautilus.desktop"
          "io.gitlab.news_flash.NewsFlash.desktop"
          "org.freecad.FreeCAD.desktop"
          "freetube.desktop"
        ];
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

    services.nextcloud-client = { 
      enable = true;
      startInBackground = true;
    };

    xdg = {
      enable = true;
      configFile."weechat/irc.conf"= {
        source = ./config-files/weechat/irc.conf;
      };
    }; 


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

    programs.tmux = {
      extraConfig = ''
	set -g default-terminal "tmux-256color"
	set -g mouse on
	set -g @plugin 'tmux-plugins/tmux-yank'
	set -g @yank_with_mouse on
	set -g @yank_selection 'primary'
      '';
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
