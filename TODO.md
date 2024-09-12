# TODO

Some things I'd like to improve :grin:

Some immediate things

* profile startup its getting slower
  * zsh
  * nvim
    * make dap lazy load

```
mason-lspconfig.nvim 108.75ms 🚀 start
nvim-cmp 59.82ms 🔌 mason-lspconfig.nvim
telescope.nvim 43.93ms 🚀 start
lazy.nvim 41.74ms 📄 init.lua
nvim-treesitter 37.51ms 🚀 start
LuaSnip 33.04ms 🔌 nvim-cmp
lualine.nvim 29ms 🚀 start
nvim-treesitter-textobjects 17.34ms 🔌 nvim-treesitter
nvim-dap-ui 15.51ms 🚀 start
gitsigns.nvim 5.54ms 🚀 start
vim-dogrun 5.42ms 🚀 start
mason.nvim 4.68ms 🔌 mason-lspconfig.nvim
nvim-autopairs 3.31ms 🔌 nvim-cmp
mason-tool-installer.nvim 3.09ms 🚀 start
nvim-lint 2.71ms 🚀 start
nvim-dap 2.61ms 🔌 nvim-dap-ui
nvim-lspconfig 2.01ms 🔌 mason-lspconfig.nvim
vim-surround 1.62ms 🚀 start
nvim-web-devicons 1.41ms 🔌 lualine.nvim
cmp-path 0.95ms 🔌 nvim-cmp
cmp-nvim-lua 0.92ms 🔌 nvim-cmp
cmp-cmdline 0.89ms 🔌 nvim-cmp
lspkind-nvim 0.82ms 🔌 nvim-cmp
nvim-nio 0.81ms 🔌 nvim-dap-ui
cmp_luasnip 0.8ms 🔌 LuaSnip
cmp-buffer 0.7ms 🔌 nvim-cmp
telescope-dap.nvim 0.66ms 🔌 telescope.nvim
cmp-nvim-lsp 0.65ms 🔌 nvim-cmp
plenary.nvim 0.61ms 🔌 telescope.nvim
telescope-repo.nvim 0.46ms 🔌 telescope.nvim
telescope-ui-select.nvim 0.44ms 🔌 telescope.nvim
telescope-fzf-native.nvim 0.39ms 🔌 telescope.nvim
neodev.nvim 0.33ms 🔌 mason-lspconfig.nvim
vim-repeat 0.16ms 🚀 start
```

* sql
  * https://github.com/tpope/vim-dadbod

* when do I use \ day to day? Should I give its prime spot to something else like !
when escaping a char inside a string

* RELOAD plugin does not seem to work
* fix debugging Go
* try setting lua_ls diagnostics.globals for my globals?
* go through vim related TODOs in my dotfiles
* remove unused alias based on shell history stats

# Keyboard

* cannot navigate to diagnostics with [d ]d with external keyboard, does it have to do with layers?
* can I get ctrl on the left hand? I want to use increase the font size using ctrl and the wheel
* the hold+modifier works but not for all combinations and apps. I can increase the size in the
browser but not decrease it. I cannot increase the font size in the terminal. What is the difference
in pressing Ctlr-+ via two separate keys and via this layer switch and hold+modifier?

# Alacritty

# nvim

* can I implement cycling through the quickfixlist?
* test quickfixlist mappings

## Java/DHIS2

* treesitter:
  * how can I jump to the class and between methods?
* ignore TE in codespell seems to be causing all kinds of issues :joy:
* fix installation of jdtls via mason
* pick a formatter for markdown
* create a UID function for dynamic vars in .http files
* try trouble plugin? how can I see diagnostics if the hint is not visible. Or can I wrap the hint?
* testing
  * output of assertEquals on the cmdline is annoying for complex objects. why is there no diffing
  :(
* postfix snippets show up but the code that is inserted is garbage
https://github.com/eclipse-jdtls/eclipse.jdt.ls/pull/2275

## Plugins

### neodev

* register my globals.lua so their usage does not appear as a warning
* I cannot navigate to implementations in nvim dotfiles. Could it be that the folke neodev plugin is
  not setup correctly? I think this worked before with my own setup.

### Telescope

* there might be some interesting configs/mappings in here
https://github.com/LazyVim/LazyVim/blob/68ff818a5bb7549f90b05e412b76fe448f605ffb/lua/lazyvim/plugins/editor.lua#L114
* quickly reload the module I just changed after opening it up using the telescope dotfiles function

### nvim-config

* what is the cleanest, most understandable way and maybe vim/nvim best
practices on how to configure language specifics. for example I would like to
configure go things in lua but some configs might be better placed into
after/ftplugin/go.vim ? like autocommands. but if these configs refer to
functions defined in lua its annoying having to jump back and forth between
these 2 files

### LSP

* cannot get https://neovim.io/doc/user/lsp.html#lsp-defaults-disable to work to remove the newly
added defaults
* go through LSP config and how to enable hints or overlays again
* autoformat for all lsps that support it instead of per language?
* does the yaml LSP use the right schema for ansible tasks? too many errors :|

### Lua

* why does the lsp say 'accessing undefined variable Print()' even though the go to definition and
signature help is working. Seems like neodev has set this up for me. Do I need to register this
global somewhere? Its like with luasnip that provides the snippet functions in the environment in
which the snippet files will be executed.

### Treesitter

* dic deletes the curlies of the conditional which I'd like to keep
* saving the playground query does not work. I get error buftype not set
* try swapping arguments by treesitter text objects plugin
* try out folding with treesitter
* double check treesitter playground config

### luasnip

* why can't I expand LSP snippets (in lua) using C-k like I can my own luasnips?
* create snippet only loaded in reporting for yesterday, today, tomorrow and month

* trying https://github.com/L3MON4D3/LuaSnip/wiki/Nice-Configs#hint-node-type-with-virtual-text
 if I do not fully finish completing the snippet the virt_text remains even
 after deleting the snippet
 is that config helping me in any way? find a snippet I use with a choice
 node. how to delete the added virtual text if completion fails?
 https://github.com/L3MON4D3/LuaSnip/issues/937

### cmp

* remove the entry or close cmp if the word matches exactly the completion entry and is not a
snippet
* toggle cmp: find a comfortable keymap on new keyboard. Can I find one to toggle? Instead of
C-space to activate and C-e to close.

### gitsigns

* use it more to navigate and stage hunks?
https://github.com/nvim-lua/kickstart.nvim/blob/76c5b1ec57f40d17ac787feb018817a802e24bb6/init.lua#L129

### nvim-lint

* maybe interesting https://github.com/mfussenegger/nvim-lint/issues/376
* I can't navigate to shellcheck diagnostics
* shellcheck ignore like `# shellcheck disable=SC2046` do not remove the linting error shown

### vim-dogrun colorscheme

* https://github.com/wadackel/vim-dogrun/issues/17
* fix cmp/luasnip code preview window
* are all telescope highlights defined in dogrun?
* fix my rg colorscheme in telescope preview. It looks different than the one in the buffer
* share my alacritty config?

### Go

* check the LSP postfix snippets, compare them with my snippets. How can they complement each other?
* implement fmta_call and use it
* use sn_list where possible
* allow making a dependency required in GoModAdd. What is a good signature for add_dependency now?
* continue on GoModPick

* create table driven test templates for map tests
* validation of golangci-lint yaml doesn't work. check LSP config
* what code actions are supported? I can only get it to work in a go.mod on a dependency
* try running go code action test. how do I see its test failure?

### Style

* colors in vimdiff look terrible :joy:

# ansible

* create reusable task or a module for the git clone -> run something on a new release task
* automate install of https://github.com/JohnnyMorganz/StyLua/releases
* automate setup of dhis2.conf / also maybe move the DHIS2_HOME somewhere else to prevent it filling up my home ;)
* automate golang setup
* install tmux plugins?
* download latest restic via the latest tag release info JSON as I do for neovim/bat/fd?
* automate https://docs.npmjs.com/resolving-eacces-permissions-errors-when-installing-packages-globally#manually-change-npms-default-directory
* TASK [base : Add docker apt repository] *************************************************************************************************************************************
fatal: [localhost]: FAILED! => {"changed": false, "msg": "Failed to update apt cache: W:GPG error: https://download.docker.com/linux/debian bullseye InRelease: The following signatures couldn't be verified because the public key is not available: NO_PUBKEY 7EA0A9C3F273FCD8, E:The repository 'https://download.docker.com/linux/debian bullseye InRelease' is not signed."}
* run apt update before installing docker, so after adding the repo. unless it is done by ansible anyway
* Add user to docker group, do I have a become: yes ? why does it fail with cannot lock /etc/passwd?
* same with GH CLI I use https://github.com/cli/cli/blob/trunk/docs/install_linux.md every time

# tmux

* is there a better shortcut for navigating between panes in tmux and splits in vim? I would love to
use C-l/k without a tmux prefix or having to repeat them in my terminal within tmux
* improve copy & paste workflow
* t - should toggle between my last two sessions :) like git checkout -
* try fzf plugin for tmux sessions

# zsh

* explore vim mode
* only use skdman to manage mvnd. can I get rid of sdkman?

# atuin

* figure out how https://docs.atuin.sh/configuration/config/#keymap_mode works

# Skills

## Vim

* why is a visual block mode substitution behaving as a visual (line) mode substitution?
* how to make my substitution case sensitive?
* is there a way to make motions in the command line nicer? going back a character at a time, to the
  start, end
* find a solution to Ctrl-<and any symbol> using the layer+modifier switch
  * multiline edits with my new keyboard in visual block mode. it does not work with C-c but C-{
  * how to use alternate file C-^ on my new keyboard?

