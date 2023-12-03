# Next

* when I save init.lua I see linter 1 not found
* I cannot navigate to implementations in nvim dotfiles. Could it be that the folke neodev plugin is
  not setup correctly? I think this worked before with my own setup.
* fix transition to https://github.com/LazyVim/LazyVim
* fix deprecated calls
* toggle cmp with C-space. Instead of C-space to activate and C-e to close. that does not make sense
  on my new keyboard layout
* enable mouse in vim to resize
* navigate between tmux windows using the same keys as in vim instead of C-w prefix is then C-s
* go through https://github.com/nvim-lua/kickstart.nvim/blob/master/init.lua again :)
* go through TODOs in my dotfiles

# nvim

* can I implement cycling through the quickfixlist?
* test quickfixlist mappings
* remove trailing whitespace via lua function registered in an autocommand?
https://github.com/mjlbach/defaults.nvim/wiki/Additional-keybinds-and-utility-functions
* show diagnostics stats in statusline :) https://github.com/mfussenegger/dotfiles/blob/0a188517e45b8f1447ef765cc95eaeeae25fc7e3/vim/.config/nvim/lua/me/init.lua#L21-L27
  lua-line does that for me as well

## Skills

### Vim

* why is a visual block mode substitution behaving as a visual (line) mode substitution?
* how to make my substitution case sensitive?
* is there a way to make motions in the command line nicer? going back a character at a time, to the
  start, end

* find a solution to Ctrl-<and any symbol> using the layer+modifier switch
  * multiline edits with my new keyboard in visual block mode. it does not work with C-c but C-{
  * how to use alternate file C-^ on my new keyboard?

## Style

* colors in vimdiff look terrible :joy:
* make a PR in vim-dogrun for diagnostic colors

## Plugins

* go through all plugins to see how to best use/configure them. Move all keymappings into the keys
key of lazy if possible.
  * luasnip
    * why can't I expand LSP snippets (in lua) using C-k like I can my own luasnips?
  * cmp
    * the code preview window should maybe use the same colors as the completion window. Right now
    it has the same as the buffer which looks odd.
    * use enter to select? it does work if there is only one entry (I think I have set that up).
    Also use it for when there is more than one?
  * telescope
    * https://github.com/LazyVim/LazyVim/blob/68ff818a5bb7549f90b05e412b76fe448f605ffb/lua/lazyvim/plugins/editor.lua#L114
  * vim-go: do I still need this plugin?
  * 'tpope/vim-repeat' do I need this?
* check https://www.lazyvim.org/plugins

### Telescope

* can I open a dotfile in a new tab via the dotfile function? Yes, with C-t. I could then use :lcd to set the dir
to the dotfile dir in that tabs window. Can I override the C-t action with that behavior just for my
dotfile mapping?
* quickly reload the module I just changed after opening it up using the telescope dotfiles function

### nvim-config

* what is the cleanest, most understandable way and maybe vim/nvim best
practices on how to configure language specifics. for example I would like to
configure go things in lua but some configs might be better placed into
after/ftplugin/go.vim ? like autocommands. but if these configs refer to
functions defined in lua its annoying having to jump back and forth between
these 2 files

### LSP

* try running go code action test. how do I see its test failure?
* go through LSP config and how to enable hints or overlays againt
* should I install stylua automatically? how do I connect it then? via mfussenneger lint?
  I use it in my git hook to format. or use nvim-format
* autoformat for all lsps that support it instead of per language?
* does the yaml LSP use the right schema for ansible tasks? too many errors :|
* lua lsp format looses my current position

## Treesitter

* saving the playground query does not work. I get error buftype not set

### luasnip

* write my own snippets
  * sometimes the virtual text of the choice node gets stuck
* exercise tune snippet navigation/selection/expansion
weird behavior: when starting a snippet, every template var I land on
I first am in vim selection mode. Once I type I am in insert mode.
I cannot simply accept the default template var for example the
i in the for i := 0, .. loop and jump to the next var with tab.
I can only jump using tab when in insert mode. However, I can also
not jump in insert mode when the node in question triggers cmp completion.
I then have to add a space to get rid of cmp dropdown and then I can jump
using tab. but that jumbles up the code. there is probably another
way to stop cmp. but either way that all feels very awkward.
* create snippet only loaded in reporting for yesterday, today, tomorrow and month

* trying https://github.com/L3MON4D3/LuaSnip/wiki/Nice-Configs#hint-node-type-with-virtual-text
 if I do not fully finish completing the snippet the virt_text remains even
 after deleting the snippet
 is that config helping me in any way? find a snippet I use with a choice
 node. how to delete the added virtual text if completion fails?

### cmp

* improve vim autocompletion experience.
  * can I change the background color of the preview? Since it has the same as the code its not as
  easy to discern.

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

* validation of golangci-lint yaml doesnt work. check LSP config
* remove vim-go plugin? what am I using it for now that the LSP is working well

# ansible

* create reusable task or a module for the git clone -> run something on a new release task
* automate install of hadolint
* automate install of https://github.com/JohnnyMorganz/StyLua/releases
* automate setup of dhis2.conf / also maybe move the DHIS2_HOME somewhere else to prevent it filling up my home ;)
* automate golang setup
* install tmux plugins?
* :GoInstallBinaries does not seem to be run when first installing vim plugins although I have the
Plug do clause
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
