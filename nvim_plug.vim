" Specify a directory for plugins
" - For Neovim: ~/.local/share/nvim/plugged
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.config/nvim/plugged')

" Fuzzy seach (main command :Files)
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

" Nice status bar
Plug 'itchyny/lightline.vim'

" Select the same word (Ctrl-n -> I, A, s, c)
Plug 'terryma/vim-multiple-cursors'

" Adds command :Rename
Plug 'danro/rename.vim'

" Surround a word or a line.
" Basic: ysiw}])>, ysW]}>, yss}]>, ds]}>
" Tags: ysiw<h1>, yss<h1>, dst
Plug 'tpope/vim-surround'

" File tree, open with :NERDTreeToggle
Plug 'scrooloose/nerdtree'

" Support for .editorconfig
Plug 'editorconfig/editorconfig-vim'

" Emmet. Enter -> Normal Mode -> Ctrl-Y ,
Plug 'mattn/emmet-vim'

" Linter
Plug 'w0rp/ale'

" Shows git changes next to line numbers
Plug 'airblade/vim-gitgutter'

" Monokai colorscheme
Plug 'crusoexia/vim-monokai'

" Un-/Comment (<Leader>cu, <Leader>cc)
Plug 'scrooloose/nerdcommenter'

" Increment/Decrement dates (Ctrl-a, Ctrl-x)
Plug 'tpope/vim-speeddating'

" Adds some nice extra's for working with md docs
Plug 'SidOfc/mkdx'

" Clickable links
Plug 'gu-fan/clickable.vim'

Plug 'itchyny/lightline.vim'

" Initialize plugin system
call plug#end()
