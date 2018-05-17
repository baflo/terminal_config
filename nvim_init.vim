" First do all plugins!!
source ~/.config/nvim/nvim_plug.vim

" Set <Leader> key
let mapleader = ","

" Reduce timeout for <ESC>
set timeoutlen=1000 ttimeoutlen=0

" Set other things
filetype plugin on
colorscheme monokai

" Add custom commands
:command! Rdate exec 'normal i'.substitute(" ".system("date +%Y-%m-%d"),"[\n]*$","","")

" Set key mappings
map <C-o> :NERDTreeToggle<CR>
map <Leader>. :Rdate<CR>
tnoremap <Esc>  <C-\><C-n>
