" Write all buffers before navigating from Vim to tmux pane
let g:tmux_navigator_save_on_switch = 2
" Disable tmux navigator when zooming the Vim pane
let g:tmux_navigator_disable_when_zoomed = 1

lua require('cmp.setup')
lua require('fugitive.setup')
lua require('go.setup')
lua require('lsp.setup')
lua require('telescope.setup')
lua require('treesitter.setup')
