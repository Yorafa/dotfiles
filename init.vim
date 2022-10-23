:set number
:set relativenumber
:set autoindent
:set tabstop=4
:set shiftwidth=4
:set smarttab
:set softtabstop=4

call plug#begin()

Plug 'vim-airline/vim-airline' " status bar

Plug 'preservim/nerdtree' " directory

Plug 'https://github.com/tpope/vim-commentary' " hotkey for comment by <gcc> and <gc>

Plug 'https://github.com/tpope/vim-surround' " fast to edit tag

Plug 'https://github.com/ap/vim-css-color'

Plug 'https://github.com/rafi/awesome-vim-colorschemes'

Plug 'ryanoasis/vim-devicons' " icons collection

Plug 'neoclide/coc.nvim', {'branch': 'release'} " auto completion

Plug 'https://github.com/preservim/tagbar' "

Plug 'wakatime/vim-wakatime'

Plug 'windwp/nvim-autopairs'

Plug 'github/copilot.vim'

call plug#end()

" map key
nnoremap <C-n>	:NERDTree<CR>
nmap <F8>	:TagbarToggle<CR>
map <C-h> <Home>
imap <C-h> <Home>
vmap <C-h> <Home>
map <C-l> <End>
imap <C-h> <Home>
vmap <C-h> <Home>

" theme
:colorscheme hybrid

" use <tab> for trigger completion and navigate to the next complete item
function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

inoremap <silent><expr> <Tab>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()

lua << EOF
require("nvim-autopairs").setup {}
EOF

" Compile and Run from extend.vim by amix/vimrc

map <F5> :call CompileRun()<CR>
imap<F5> <Esc>:call CompileRun()<CR>
vmap<F5> <Esc>:call CompileRun()<CR>

func! CompileRun()
	exec "w"
	if &filetype == 'c'
		exec "!gcc -Wall -g % -o %<"
		exec "!time ./%<"
	elseif &filetype == 'cpp'
		exec "!g++ % -o %<"
	    exec "!time ./%<"
	elseif &filetype == 'java'
		exec "!javac %"
	    exec "!time java %"
	elseif &filetype == 'sh'
		exec "!time bash %"
	elseif &filetype == 'python'
		exec "!time python3 %"
	elseif &filetype == 'html'
		exec "!google-chrome % &"
	elseif &filetype == 'go'
		exec "!go build %<"
	    exec "!time go run %"
	elseif &filetype == 'matlab'
		exec "!time octave %"
	endif
endfunc

