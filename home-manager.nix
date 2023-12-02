{ config, pkgs, home-manager, ... }:
#let
#  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-23.11.tar.gz";
##  nur = builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz";
#in
{
  imports = [
 #   (import "${home-manager}/nixos")
    <home-manager/nixos>
  ];

  home-manager.users.mickael = {
    home.stateVersion = "23.05";

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
      }; 
    };

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;


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
      profiles = {
        mickael = {
          extensions = with pkgs.nur.repos.rycee.firefox-addons; [
                ublock-origin
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

    programs.neovim = {
  
      enable = true;
 
#      coc.enable = true;

      plugins = with pkgs.vimPlugins; [
        lazy-nvim 
        clangd_extensions-nvim
        nvim-lspconfig 
      ];

      extraLuaConfig = builtins.readFile ./config-files/neovim/init.lua;
  
    };

    services.copyq.enable = true;

  };
}
