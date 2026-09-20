syntax on

set belloff=all
set tabstop=4 softtabstop=4 
set shiftwidth=4
set expandtab
set smartindent
set nohlsearch
set nu
set nowrap
set smartcase
set noswapfile
set nobackup
set undodir=~/.vim.undodir
set undofile
set incsearch
set scrolloff=8
set completeopt=menuone,noinsert,noselect
set signcolumn=yes
set runtimepath^=~/.vim/bundle/ctrlp.vim
set backspace=indent,eol,start

set colorcolumn=80
highlight ColorColumn ctermbg=0 guibg=lightgrey

" WSL yank support
" change this path according to your mount point
" let s:clip = '/mnt/c/Windows/System32/clip.exe'
" if executable(s:clip)
"     augroup WSLYank
"         autocmd!
"         autocmd TextYankPost * if v:event.operator ==# 'y' | call system(s:clip, @0) | endif
"     augroup END
" endif

call plug#begin('~/.vim/plugged')

    Plug 'gruvbox-community/gruvbox'
    Plug 'jremmen/vim-ripgrep'
    Plug 'tpope/vim-fugitive'
    Plug 'leafgarland/typescript-vim'
    Plug 'vim-utils/vim-man'
    Plug 'lyuts/vim-rtags'
    Plug 'ctrlpvim/ctrlp.vim'
    Plug 'ycm-core/YouCompleteMe'
    Plug 'mbbill/undotree'

call plug#end()

colorscheme gruvbox
set background=dark
"let g:gruvbox_contrast_dark = 'hard'

if executable('rg')
    let g:rg_derive_root='true'
endif

let g:ctrlp_user_command = ['.git/', 'git --git-dir=%s/.git ls-files -oc --exclude-standard']
let mapleader = " "
let g:netrw_browse_split=2
let g:netrw_banner=0
let g:netrw_winsize=25

let g:ctrlp_use_caching=0


" editing cursor appearance 
" let &t_SI = "\<Esc>[6 q" " blinking I beam cursor for insert mode
" let &t_EI = "\<Esc>[2 q" " steady block cursor for normal mode
" let &t_SR = "\<Esc>[4 q" " underline cursor for replace mode

let &t_SI .= "\<Esc>[6 q"
let &t_EI .= "\<Esc>[2 q"
let &t_SR .= "\<Esc>[4 q"

" from kitty issue #4234, to edit cursor appearance for kitty
if $TERM == "xterm-kitty"
    set mouse=a
    try
        " undercurl support
        let &t_Cs = "\e[4:3m"
        let &t_Ce = "\e[4:0m"
    catch
    endtry
    " vim hardcodes background color erase even if the terminfo file does
    " not contain bce. This causes incorrect background rendering when
    " using a color theme with a background color.
    let &t_ut=''
endif 

let &t_ti = &t_ti . "\e[2 q"

let &t_te.="\e[0 q"  "t_te = Termcap End - usually called when exiting Vim.

" reset the cursor on start (for older versions of vim, usually not required)
augroup myCmds
au!
autocmd VimEnter * silent !echo -ne "\e[2 q"
augroup END

" ensures cursor switches immediately
set ttimeout
set ttimeoutlen=1
set ttyfast

nnoremap <leader>h :wincmd h<CR>
nnoremap <leader>j :wincmd j<CR>
nnoremap <leader>k :wincmd k<CR>
nnoremap <leader>l :wincmd l<CR>
nnoremap <leader>u :UndotreeShow<CR>
nnoremap <leader>pv :Vex <CR>
nnoremap <leader>ps :Rg<SPACE>
nnoremap <silent> <Leader>+ :vertical resize +5<CR>
nnoremap <silent> <Leader>- :vertical resize -5<CR>

" YCM (the best part?)
nnoremap <silent> <Leader>gd :YcmCompleter GoTo<CR>
nnoremap <silent> <Leader>gf :YcmCompleter FixIt<CR>
