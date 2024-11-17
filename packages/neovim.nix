{ config, pkgs, programs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;

    # viAlias = true;
    vimAlias = true;

    configure = {
      customRC = ''
        set number
        set cc=80
        set list
        set listchars=tab:→\ ,space:·,nbsp:␣,trail:•,eol:¶,precedes:«,extends:»
        if &diff
          colorscheme blue
        endif
      '';
      packages.myVimPackage = with pkgs.vimPlugins; {
        start = [
          ctrlp
          nvim-treesitter
          nvim-tree-lua
          vim-startify
        ];
      };
    };
  };
}

