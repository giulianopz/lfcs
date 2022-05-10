## vi(m)

### Minimal Configuration

Type the following lines into `~/.vimrc`:
```
set nocompatible    # make vim not campatible with vi
filetype off        # disable file type detection
set hlsearch        # highlight all search results
set ignorecase      # do case insensitive search 
set incsearch       # show incremental search results as you type
set number          # display line number
set noswapfile      # disable swap file
```

I found the first two lines necessary to solve the common [problem](https://vim.fandom.com/wiki/Fix_arrow_keys_that_display_A_B_C_D_on_remote_shell) with arrow keys misinterpreted as A, B, C, D.

More on vim:

1. [interactive Vim tutorial](https://www.openvim.com/)
2. [Learn Vim (the Smart Way)](https://github.com/iggredible/Learn-Vim)
3. [Vim tips & tricks](https://www.cs.swarthmore.edu/oldhelp/vim/home.html)