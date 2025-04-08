# TODO

Some things I'd like to improve :grin:

* :Work pr create/view
  * test next time I create one

* try postgres lsp

* [waiting on release] https://ghostty.org/docs/config/keybind/reference#toggle_quick_terminal
  * should land in 1.2, the necessary dependencies should be packaged into the snap
  https://github.com/ghostty-org/ghostty/blob/17ba0252e831457418da1b5c26ce16bdf83f0e5c/snap/snapcraft.yaml#L76-L77
  https://github.com/ghostty-org/ghostty/pull/6027

* zsh
  * decrease KEYTIMEOUT again, what works with zsh vim and fzf bindings?

## stow

* Use `--dotfiles` once https://github.com/aspiers/stow/issues/33 release 2.4.0 is available to me.
  This gets rid of the many hidden dirs :joy:

## nvim

* dotfiles lua: accessing undefined global
  * setting non-standard global variable
* vimdiff highlight like in terminal without background color?

### Plugins

#### Test runner

* test runner
  * use different mappings than 'f' and 'a'? maybe <leader>tf? or take inspiration from Oil
  * add help float for mappings
  * add mark if I ran a single test like the nearest/last test `T`
  * could I add marks like vimium onto the failed tests in the terminal buffer and re-run only a
  single one on keypress?
  * put the test I run into focus?
    * no matter if I run it via telescope or run nearest?
  * how to cancel the test run?
  * using vim.system
    * pro
      * I know when my command finished and can react to it, or can I do the same in the terminal?
      * I don't have to deal with the buffer being in a partial state like the terminal having a
      command on the prompt that I have not executed to which I then append the test command. Could
      always clear that to be on the safe side
    * con
      * cannot see test runs live, or can I stream the changes into the buffer? dhis2 runs take
      forever
      * cannot re-run/tweak that command directly in the terminal buffer anymore
  * can I react to maven printing FAILURE if the build fails? using backwards search and this word I
  can more easily find what's wrong in this huge log. I assume the first match is what I want. Might be
  tricky if I have multiple runs in the buffer. Seems like there is `FAILURE!` an exclamation mark
  only once. Check the presentation where they make some kind of objects like fugitive for hashes.

  it would also be useful for Go to navigate with something like ]f or ]t between failures

    --- FAIL: TestParser/Subgraph (0.00s)
        --- FAIL: TestParser/Subgraph/SubgraphWithAttributesAndNodes (0.00s)

#### lazydev

* why does the LSP start with so many errors and then sometimes recovers?
* why does the lsp say 'accessing undefined variable Print()' even though the go to definition and
signature help is working. Seems like neodev has set this up for me. Do I need to register this
global somewhere? Its like with luasnip that provides the snippet functions in the environment in
which the snippet files will be executed.

#### Telescope

* how to use the ts top function in the telescope previewer? via the ft hook? just seeing the
comment in dhis2
* experiment with telescope prompt history
* quickly reload the module I just changed after opening it up using the telescope dotfiles function

#### LSP

* adapt my config to the new config API
* cannot get https://neovim.io/doc/user/lsp.html#lsp-defaults-disable to work to remove the newly
added defaults. I want to keep my C-s for tmux and C-k for the signature help. So disable C-s

* does the yaml LSP use the right schema for ansible tasks? too many errors :|
* is it useful to only add key map if the LSP has the capability see
https://github.com/mfussenegger/dotfiles/blob/c878895cbda5060159eb09ec1d3e580fd407b731/vim/.config/nvim/lua/me/lsp/conf.lua#L51

#### StyLua

* ignores column_width has no effect on comments at least line comments

#### Treesitter

* how to quickly iterate on a ts query file?

#### nvim-lint

* maybe interesting https://github.com/mfussenegger/nvim-lint/issues/376
* I can't navigate to shellcheck diagnostics
* shellcheck ignore like `# shellcheck disable=SC2046` do not remove the linting error shown

#### vim-dogrun colorscheme

* https://github.com/wadackel/vim-dogrun/issues/17
* fix my rg colorscheme in telescope preview. It looks different than the one in the buffer

#### Go

* can I use `go test -list .` to list all tests?
* check the LSP postfix snippets, compare them with my snippets. How can they complement each other?
* implement fmta_call and use it
* use sn_list where possible
* allow making a dependency required in GoModAdd. What is a good signature for add_dependency now?
* continue on GoModPick

* create table driven test templates for map tests
* validation of golangci-lint yaml doesn't work. check LSP config
* try running go code action test. how do I see its test failure?

## Ansible

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

## zsh

* how to autoload my zsh-scripts? would I need to write them differently? there is this convention
of creating a file per function. would be great to avoid having to create many small files.
* find a better bindings for Docker and Kubernetes widgets than C-a. Using ones I use for other
things like C-a slows me down as I need to wait for $KEYTIMEOUT. Using "destructive" ones like C-d
or C-w think docker or whale is annoying if I don't type the second key it will fallback and send a
signal or delete a word

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

### Vim

* try explaining the behavior of a move I often make: I think in insert mode C-O and then e and it
does not reach the end but looks like an off by one error.
* how can I join lines while I am in insert mode? I sometimes add a newline by accident after
opening braces
* why is a visual block mode substitution behaving as a visual (line) mode substitution?
* how to make my substitution case sensitive?

## Docs

https://github.com/luvit/luv/blob/master/docs.md
https://docs.libuv.org/en/v1.x/

