{ config, pkgs, programs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;

    # viAlias = true;
    vimAlias = true;

    configure = {
      customRC = ''
        set cc=80
        set list
        set listchars=tab:→\ ,trail:•,precedes:«,extends:»
        colorscheme habamax
      '';
        # set number
        # set clipboard+=unnamedplus
        # set listchars=tab:→\ ,space:·,nbsp:␣,trail:•,eol:¶,precedes:«,extends:»
        #if &diff
        #endif
      packages.myVimPackage = with pkgs.vimPlugins; {
        start = [
          (nvim-treesitter.withPlugins (
            plugins: with plugins; [
              nix
              python
              bash
              c
            ]
          ))
          telescope-nvim
          vim-commentary # gcc
          vim-startify
        ];
      };
    };
  };
}
