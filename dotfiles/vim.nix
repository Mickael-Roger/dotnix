{
  config,
  pkgs,
  lib,
  ...
}:
let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-23.05.tar.gz";
in
{
programs.vim = {
  plugins = with pkgs.vimPlugins; [
    vim-addon-nix
    vim-nix
    nerdtree
    nerdtree-git-plugin
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
     
    call plug#begin()
    " Bash
    Plug 'vim-scripts/bash-support.vim'
    
    call plug#end()

    autocmd StdinReadPre * let s:std_in=1
    autocmd VimEnter * NERDTree | if argc() > 0 || exists("s:std_in") | wincmd p | endif
    autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif

    autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
    au BufNewFile,BufRead *.yaml,*.yml so ~/.vim/yaml.vim

  '';
};
}

