# dotfiles

My personal dotfiles 🗂

## Installation

Run inside of terminal and not alacritty

```sh
ansible-playbook playbooks/home.yml
```

In case of an alacritty update ansible will replace the alacritty binary. If an
alacritty process is running ansible will fail to replace the binary.

## Development

Setup git hook

```sh
ln -sf ../../pre-commit.hook .git/hooks/pre-commit
```

## Inspiration & Gratitude

Thank you very much to

- https://github.com/fatih/dotfiles
- https://github.com/junegunn/dotfiles
- https://github.com/mfussenegger/dotfiles

for helping me getting my home in order ☺️

## Learning Resources

- http://vimcasts.org/
- https://www.hamvocke.com/blog/a-guide-to-customizing-your-tmux-conf/
- https://thoughtbot.com/upcase/tmux
