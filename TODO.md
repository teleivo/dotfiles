# TODO

Some things I must fix

ansible
* compile DHIS2/run perf test setup
  * test making .http from nvim
* restic self-update
* path issues with node and ./local/bin: is there a better way?
* move stow tasks into individual tasks/close to where its needed?
* can we make this less scary

TASK [rust : Check if rustup exists] ************************************************************************
[ERROR]: Task failed: Module failed: non-zero return code
Origin: /home/ivo/code/dotfiles/ansible/playbooks/roles/rust/tasks/main.yml:2:3

1 ---
2 - name: Check if rustup exists
    ^ column 3

fatal: [localhost]: FAILED! => {"changed": false, "cmd": ["which", "rustup"], "delta": "0:00:00.002166", "end": "2025-11-14 11:38:02.545741", "msg": "non-zero return code", "rc": 1, "start": "2025-11-14 11:38:02.543575", "stderr": "", "stderr_lines": [], "stdout": "", "stdout_lines": []}
...ignoring

or

TASK [vim : Check if neovim is already installed] ***********************************************************
[ERROR]: Task failed: Module failed: non-zero return code
Origin: /home/ivo/code/dotfiles/ansible/playbooks/roles/vim/tasks/main.yml:27:3

25   register: neovim_changed
26
27 - name: Check if neovim is already installed
     ^ column 3

fatal: [localhost]: FAILED! => {"changed": false, "cmd": ["which", "nvim"], "delta": "0:00:00.002130", "end": "2025-11-14 11:59:55.332007", "msg": "non-zero return code", "rc": 1, "start": "2025-11-14 11:59:55.329877", "stderr": "", "stderr_lines": [], "stdout": "", "stdout_lines": []}
...ignoring


* change fd colors to use the green of constants for files and the blue of the PS instead of the
bright one
* voyager multimedia layer now works but the same layer also has home, prev, next, end navigation
which dont work anymore and some seem to trigger multimedia keys

Some things I'd like to improve :grin:

* :Work pr create/view
  * test next time I create one

* try postgres lsp

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

#### nvim-treesitter Migration (master → main)

**Current Status**: Pinned to commit `310f0925` (last master commit before `configs.lua` removal)

**Why This Feels Like A Step Back**

The main branch rewrite represents a fundamental philosophy shift that reduces the plugin's scope:

* **Old philosophy**: Full-featured convenience layer that managed everything (parser installation,
automatic feature enabling, module framework for other plugins)
* **New philosophy**: Lean parser/query manager that delegates feature activation to you and
Neovim core

The plugin no longer handles enabling features automatically. You must manually activate
highlighting (`vim.treesitter.start()`), folding (`foldmethod='expr'`, `foldexpr`), and
indentation using Neovim core APIs. This is intentional - they want to stop maintaining parallel
abstractions as Neovim core has absorbed most tree-sitter capabilities.

The module framework that other plugins relied on (like `nvim-autopairs`, `nvim-treesitter-
textobjects`) is completely removed. These plugins must now integrate directly with Neovim's
tree-sitter APIs instead of going through nvim-treesitter's abstraction layer.

**Why The tree-sitter CLI Is Now Required**

* The CLI tool compiles parser grammars from source code
* Previously nvim-treesitter bundled pre-compiled parsers (convenient but massive maintenance
burden)
* Now follows Neovim core's approach: compile parsers on-demand using the CLI tool
* This aligns with upstream tree-sitter project and enables cross-editor query sharing with Helix
and others
* Known issue: Installation silently fails without helpful error messages when CLI is missing

**The Architecture Problem They Solved**

* Old module system added significant overhead and made it hard to implement changes without
breaking other plugins
* As Neovim core absorbed more tree-sitter features, the plugin's abstraction layer became
increasingly redundant
* Maintainers wanted closer alignment with upstream tree-sitter ecosystem rather than maintaining
an isolated, Neovim-specific implementation
* The "full rewrite" was necessary because incremental changes would have been impossible without
breaking everything anyway

**Breaking Changes Summary**

* `require('nvim-treesitter.configs')` → completely removed
* `require('nvim-treesitter.ts_utils')` → removed (use `vim.treesitter.*` APIs)
* `require('nvim-treesitter.locals')` → removed (no direct replacement)
* `ensure_installed` option → removed (must install parsers manually via
`require('nvim-treesitter').install()`)
* Feature toggles like `highlight = { enable = true }` → removed (enable manually via Neovim core)
* Module framework for plugins → removed (plugins handle their own setup)

**Files Affected By Migration**

1. `nvim/.config/nvim/lua/plugins/treesitter.lua` - Complete rewrite required
2. `nvim/.config/nvim/lua/my-treesitter/init.lua` - Uses removed `ts_utils.get_root_for_position()`
3. `nvim/.config/nvim/luasnip/go.lua` - Uses removed `ts_utils.get_node_at_cursor()` and
`ts_locals.get_scope_tree()`
4. `nvim/.config/nvim/lua/plugins/autopairs.lua` - May need treesitter integration updates
5. `ansible/playbooks/roles/vim/tasks/main.yml` - Must install tree-sitter CLI binary

**Decision: Stay on Master or Migrate?**

Master branch is frozen but stable and will remain available. Benefits of staying:
* Current setup works perfectly
* No migration effort required
* All custom code functions as-is
* Can migrate on your own timeline

Benefits of migrating to main:
* Future parser updates and improvements
* Better alignment with Neovim core treesitter integration
* Cross-editor query compatibility
* Active development and bug fixes

**Recommendation**: Stay on pinned master commit unless you need specific new parsers or features
only available on main. When ready to migrate, treat it as a dedicated project (2-4 hours) to
modernize your entire treesitter integration, not a simple plugin update.

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

* cannot get https://neovim.io/doc/user/lsp.html#lsp-defaults-disable to work to remove the newly
added defaults. I want to keep my C-s for tmux and C-k for the signature help. So disable C-s
* does the yaml LSP use the right schema for ansible tasks? too many errors :|
* is it useful to only add key map if the LSP has the capability see
https://github.com/mfussenegger/dotfiles/blob/c878895cbda5060159eb09ec1d3e580fd407b731/vim/.config/nvim/lua/me/lsp/conf.lua#L51

### Neovim Compatibility Updates (0.12+)

#### New Features to Consider

* **LSP Document Color Support** (`lsp-document_color`)
  * Automatically highlights color references in documents (CSS, HTML, etc.)
  * Provides color picker via `vim.lsp.document_color.color_presentation()`
  * Enabled by default when LSP server supports it
  * **Why useful**: No more guessing hex codes - see actual colors in your stylesheets

* **LSP Inline Completion** (`lsp-inline_completion`)
  * Multiline text completion (whole methods/functions) as overlay text
  * Different from regular completion - shows suggestions inline instead of popup
  * Works with Copilot, CodeWhisperer, and other AI assistants
  * Enable with `vim.lsp.inline_completion.enable()`
  * **Why useful**: AI-powered code generation directly in your editor without external plugins

* **LSP Linked Editing Range** (`lsp-linked_editing_range`)
  * Synchronizes text edits across related ranges (e.g., HTML open/close tags)
  * Changes in one location automatically update related locations
  * Enable per-client: `vim.lsp.linked_editing_range.enable(true, {client_id = client.id})`
  * **Why useful**: Edit HTML tag names without manually updating both open/close tags

* **Built-in Plugin Manager** (`vim.pack`)
  * **Work in progress** alternative to lazy.nvim with Git-based plugin management
  * Uses semantic versioning with `vim.version.range()` for version constraints
  * Interactive update confirmation with diff view and LSP support
  * Parallel installation and built-in logging
  * **Why consider**: Potential future migration path, but stick with lazy.nvim for now

* **Enhanced Diagnostics** (`vim.diagnostic.status()`)
  * Returns formatted diagnostic counts: `E:2 W:3 I:4 H:5`
  * Now included in default statusline automatically
  * **Why useful**: Your lualine config could use this for consistent diagnostic display

* **Performance Improvements**
  * New LPeg-based glob implementation (Peglob) with ~50% speedup for complex patterns
  * Better nested braces support and LSP 3.17 specification compliance
  * **Why useful**: Faster file searching, especially beneficial for telescope and large codebases

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

## wayland/sway

* configure /tmp cleaning on boot
  * create `/etc/tmpfiles.d/tmp.conf` with:
    ```
    # Clear /tmp on boot
    D /tmp 1777 root root -
    ```
  * this ensures /tmp partition is cleaned on reboot (like tmpfs behavior)

## Ansible

* pick a secret scanner and setup git pre commit hook

## zsh

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

