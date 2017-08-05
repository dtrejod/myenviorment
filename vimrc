" ----------
" - PYTHON -
" ----------
" Pathogen load
filetype off

call pathogen#infect()
call pathogen#helptags()

" Trim unused whitespace
let g:pymode_trim_whitespaces = 1

" Auto python PEP8 indentation
let g:pymode_indent = 1

" Support virtualenv
let g:pymode_virtualenv = 1

" Disable code check on every save
let g:pymode_lint_on_write = 1

" On the fly code check
let g:pymode_lint_on_fly = 0

" Disable code folding
let g:pymode_folding = 0

" Disable pyrope
let g:pymode_rope = 0

" Disable code scratch
set completeopt-=preview

" ---------------
" - Default VIM -
" ---------------
" Disable mouse
set mouse=c

filetype plugin indent on
" Set syntax always on
syntax on

" Set Tab equal to four spaces
set expandtab
set tabstop=4
set shiftwidth=4

" Shift-Tab unindents
imap <S-Tab> <C-o><<

" Show line numbers
set number

" Show vertical line at 80 chars
set colorcolumn=80

" Show current file name
set laststatus=2

" Vimdiff colors
if &diff
    colorscheme myvimdiff
endif

set background=dark

" Highlight unwanted space
:highlight ExtraWhitespace ctermbg=red guibg=red
:match ExtraWhitespace /\s\+$/

" Remember last position on opened files
if has("autocmd")
      au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
  endif

" Moving back and forth between lines of same or lower indentation.
nnoremap <silent> [l :call NextIndent(0, 0, 0, 1)<CR>
nnoremap <silent> ]l :call NextIndent(0, 1, 0, 1)<CR>
nnoremap <silent> [L :call NextIndent(0, 0, 1, 1)<CR>
nnoremap <silent> ]L :call NextIndent(0, 1, 1, 1)<CR>
vnoremap <silent> [l <Esc>:call NextIndent(0, 0, 0, 1)<CR>m'gv''
vnoremap <silent> ]l <Esc>:call NextIndent(0, 1, 0, 1)<CR>m'gv''
vnoremap <silent> [L <Esc>:call NextIndent(0, 0, 1, 1)<CR>m'gv''
vnoremap <silent> ]L <Esc>:call NextIndent(0, 1, 1, 1)<CR>m'gv''
onoremap <silent> [l :call NextIndent(0, 0, 0, 1)<CR>
onoremap <silent> ]l :call NextIndent(0, 1, 0, 1)<CR>
onoremap <silent> [L :call NextIndent(1, 0, 1, 1)<CR>
onoremap <silent> ]L :call NextIndent(1, 1, 1, 1)<CR>

" -------------
" - FUNCTIONS -
" -------------

" Jump to the next or previous line that has the same level or a lower
" level of indentation than the current line.
"
" exclusive (bool): true: Motion is exclusive
" false: Motion is inclusive
" fwd (bool): true: Go to next line
" false: Go to previous line
" lowerlevel (bool): true: Go to line with lower indentation level
" false: Go to line with the same indentation level
" skipblanks (bool): true: Skip blank lines
" false: Don't skip blank lines
function! NextIndent(exclusive, fwd, lowerlevel, skipblanks)
  let line = line('.')
  let column = col('.')
  let lastline = line('$')
  let indent = indent(line)
  let stepvalue = a:fwd ? 1 : -1
  while (line > 0 && line <= lastline)
    let line = line + stepvalue
    if ( ! a:lowerlevel && indent(line) == indent ||
          \ a:lowerlevel && indent(line) < indent)
      if (! a:skipblanks || strlen(getline(line)) > 0)
        if (a:exclusive)
          let line = line - stepvalue
        endif
        exe line
        exe "normal " column . "|"
        return
      endif
    endif
  endwhile
endfunction

