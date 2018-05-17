" Specify a directory for plugins
" - For Neovim: ~/.local/share/nvim/plugged
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.config/nvim/plugged')

" Make sure you use single quotes
Plug 'crusoexia/vim-monokai'
Plug 'scrooloose/nerdcommenter'
Plug 'tpope/vim-speeddating'
Plug 'godlygeek/tabular'

Plug 'gabrielelana/vim-markdown'
Plug 'thanthese/markdown-outline'

Plug 'itchyny/lightline.vim'

" Initialize plugin system
call plug#end()
