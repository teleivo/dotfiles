# TODO

Some things I'd like to improve :grin:

* fix lua annotations in my-go
* add command 'Go mod add' and cleanup rest of my-go
* fix state of terminal, maybe use a table/metatable Terminal.new(), term:open(), term:send()
* try reusing setup for my-java

* markdown continue list using treesitter? add to ftplugin
* telescope
  * open multiple files in split

* zsh
  * decrease KEYTIMEOUT again, what works with zsh vim and fzf bindings?

* run go test with the nearest test name using above query or pass it to vim.ui to select one from
all names
* support java: find root pom and either run all tests in class or if using nearest add the #method
  suffix

  mvn --file dhis-2/pom.xml test -Dsurefire.failIfNoSpecifiedTests=false "-Dtest=EventsExportControllerIdSchemeTest"
  mvn --file dhis-2/pom.xml test -Dsurefire.failIfNoSpecifiedTests=false "-Dtest=EventsExportControllerIdSchemeTest#method"

* fix
Reading package lists... Done
W: An error occurred during the signature verification. The repository is not updated and the previous index files will be used. GPG error: https://download.docker.com/linux/debian bookworm InRelease: The following signatures couldn't be verified because the public key is not available: NO_PUBKEY 7EA0A9C3F273FCD8
W: Failed to fetch https://download.docker.com/linux/debian/dists/bookworm/InRelease  The following signatures couldn't be verified because the public key is not available: NO_PUBKEY 7EA0A9C3F273FCD8
W: Some index files failed to download. They have been ignored, or old ones used instead.

* java
  * setup compiler settings.url
  https://gist.github.com/snjeza/e59f0ce031f237a9d0f4f2aec404a4bb
  * try cleanup.actionsOnSave
  * what are our settings for ordering imports? how can I replicate that
  * how can I navigate to an implementation and to the interface declaration?
  https://github.com/mfussenegger/nvim-jdtls/issues/634
* why does my new lsp inline mapping not work?
* run goimports again, after or before lsp?
* reduce pw burden when signing commits

## Keyboard

## Alacritty

## stow

* Use `--dotfiles` once https://github.com/aspiers/stow/issues/33 release 2.4.0 is available to me.
  This gets rid of the many hidden dirs :joy:

## nvim

* dotfiles lua: accessing undefined global
  * setting non-standard global variable

* how to quickly reload a lua module/plugin without restarting neovim
* use my top_level_declaration function whenever I open a file no matter if I do it via telescope,
netrw or else
* why does undo jump so much, at least in java
* what is the cleanest, most understandable way and maybe vim/nvim best practices on how to
configure language specifics. for example I would like to configure go things in lua but some
configs might be better placed into after/ftplugin/go.vim ? like autocommands. but if these configs
refer to functions defined in lua its annoying having to jump back and forth between these 2 files

### Java/DHIS2

* how to create a different config based on the jdk version used by the branch? some cleanups are
illegal in older versions but are still being applied
* https://www.jetbrains.com/help/idea/exploring-http-syntax.html#example-working-with-environment-files
use one env.json and private.env.json in notes? how does this influence DBUI? one .env with the DB
credentials?
* fix installation of jdtls via mason
* try trouble plugin? how can I see diagnostics if the hint is not visible. Or can I wrap the hint?
* testing
  * output of assertEquals on the cmdline is annoying for complex objects. why is there no diffing
  :(
* postfix snippets show up but the code that is inserted is garbage
https://github.com/eclipse-jdtls/eclipse.jdt.ls/pull/2275

* sql
  * make https://github.com/tpope/vim-dadbod work with my DHIS2 workflow
  * how can I make it save my query? under a name that I want?
  * how to handle different connections? use https://github.com/tpope/vim-dotenv I could define one
  in the notes/.env for local development this could also work well with the instance manager?

### Plugins

#### lazydev

* why does the LSP start with so many errors and then sometimes recovers?
* why?
  * vim.loop.fs_stat(lazypath) undefined field fs_stat
  * vim.loop.new_timer

* why does the lsp say 'accessing undefined variable Print()' even though the go to definition and
signature help is working. Seems like neodev has set this up for me. Do I need to register this
global somewhere? Its like with luasnip that provides the snippet functions in the environment in
which the snippet files will be executed.

#### Telescope

* how can I use the telescope prompt history?
* there might be some interesting configs/mappings in here
https://github.com/LazyVim/LazyVim/blob/68ff818a5bb7549f90b05e412b76fe448f605ffb/lua/lazyvim/plugins/editor.lua#L114
* quickly reload the module I just changed after opening it up using the telescope dotfiles function

#### LSP

* cannot get https://neovim.io/doc/user/lsp.html#lsp-defaults-disable to work to remove the newly
added defaults. I want to keep my C-s for tmux and C-k for the signature help. So disable C-s

* does the yaml LSP use the right schema for ansible tasks? too many errors :|
* is it useful to only add key map if the LSP has the capability see
https://github.com/mfussenegger/dotfiles/blob/c878895cbda5060159eb09ec1d3e580fd407b731/vim/.config/nvim/lua/me/lsp/conf.lua#L51

#### StyLua

* ignores column_width has no effect on comments at least line comments

#### Treesitter

* try swapping arguments by treesitter text objects plugin
* saving the playground query does not work. I get error buftype not set
* double check treesitter playground config

#### luasnip

* create snippet only loaded in reporting for yesterday, today, tomorrow and month

#### cmp

#### nvim-lint

* maybe interesting https://github.com/mfussenegger/nvim-lint/issues/376
* I can't navigate to shellcheck diagnostics
* shellcheck ignore like `# shellcheck disable=SC2046` do not remove the linting error shown

#### vim-dogrun colorscheme

* https://github.com/wadackel/vim-dogrun/issues/17
* fix cmp/luasnip code preview window
* fix my rg colorscheme in telescope preview. It looks different than the one in the buffer

#### Go

* how to organize imports again on save? or add :Go import clean
* can I use `go test -list .` to list all tests?

* check the LSP postfix snippets, compare them with my snippets. How can they complement each other?
* implement fmta_call and use it
* use sn_list where possible
* allow making a dependency required in GoModAdd. What is a good signature for add_dependency now?
* continue on GoModPick

* create table driven test templates for map tests
* validation of golangci-lint yaml doesn't work. check LSP config
* try running go code action test. how do I see its test failure?

##### Plugin

* make use of vims validate function to validate args

#### Style

## Ansible

* create reusable task or a module for the git clone -> run something on a new release task
* automate install of https://github.com/JohnnyMorganz/StyLua/releases
* automate setup of dhis2.conf / also maybe move the DHIS2_HOME somewhere else to prevent it filling
up my home ;)
* install tmux plugins?
* download latest restic via the latest tag release info JSON as I do for neovim/bat/fd?
* automate
https://docs.npmjs.com/resolving-eacces-permissions-errors-when-installing-packages-globally#manually-change-npms-default-directory
```
* TASK [base : Add docker apt repository]
*************************************************************************************************************************************
fatal: [localhost]: FAILED! => {"changed": false, "msg": "Failed to update apt cache: W:GPG error:
https://download.docker.com/linux/debian bullseye InRelease: The following signatures couldn't be
verified because the public key is not available: NO_PUBKEY 7EA0A9C3F273FCD8, E:The repository
'https://download.docker.com/linux/debian bullseye InRelease' is not signed."} ```
* run apt update before installing docker, so after adding the repo. unless it is done by ansible
anyway
* Add user to docker group, do I have a become: yes ? why does it fail with cannot lock /etc/passwd?
* same with GH CLI I use https://github.com/cli/cli/blob/trunk/docs/install_linux.md every time

## tmux

* improve copy & paste workflow
* t - should toggle between my last two sessions :) like git checkout -

## zsh

* how to autoload my zsh-scripts? would I need to write them differently? there is this convention
of creating a file per function. would be great to avoid having to create many small files.
* find a better bindings for Docker and Kubernetes widgets than C-a. Using ones I use for other
things like C-a slows me down as I need to wait for $KEYTIMEOUT. Using "destructive" ones like C-d
or C-w think docker or whale is annoying if I don't type the second key it will fallback and send a
signal or delete a word

## atuin

* fix update and then pin to a particular version
* figure out how https://docs.atuin.sh/configuration/config/#keymap_mode works

## fzf

* how to clear the screen of an execute binding? when I look at logs and then exec into the
container the logs are still around
* nice to have: keep a tmux popup border around the fzf execute actions to distinguish the popup
text from the background

control panels
* idea: add a widget to fzf-git to do something with the github cli
  * PR list/status?
  * PR review?
* create a widget for k8s logs binding it to l, this way I can generate the command like
port-forwarding and process them using jq or anything I want
* why can't I copy logs from the fzf preview or in an execute? is this related to it being a tmux
popup

## Skills

* try vi mode in vim command
* try vi mode in tmux

### Vim

* how can I join lines while I am in insert mode? I sometimes add a newline by accident after
opening braces
* why is a visual block mode substitution behaving as a visual (line) mode substitution?
* how to make my substitution case sensitive?
* is there a way to make motions in the command line nicer? going back a character at a time, to the
start, end

### zsh
