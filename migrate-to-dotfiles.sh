#!/bin/bash
set -euo pipefail

# Migration script to convert stow packages to use --dotfiles format
# This renames hidden files/dirs to use dot- prefix instead of . prefix

cd ~/code/dotfiles

echo "Starting migration to --dotfiles format..."

# List of all items to rename (package/path format)
items=(
  "alacritty/.config"
  "alias/.alias"
  "ansible/.claude"
  "atuin/.config"
  "bat/.config"
  "bin/.local"
  "chrome/.local"
  "claude/.claude"
  "dmrc/.dmrc"
  "fd/.config"
  "fuzzel/.config"
  "fzf-scripts/.fzf-scripts"
  "ghostty/.config"
  "git/.config"
  "git/.gitconfig"
  "intellij/.ideavimrc"
  "kanshi/.config"
  "mako/.config"
  "maven/.m2"
  "nerd-dictation/.config"
  "nvim/.config"
  "obs/.config"
  "pipewire/.config"
  "psql/.psqlrc"
  "rg/.config"
  "shell/.profile"
  "solaar/.config"
  "sway/.config"
  "swaylock/.config"
  "systemd/.config"
  "tmux/.tmux.conf"
  "udev/.config"
  "waybar/.config"
  "wireplumber/.config"
  "xdg-desktop-portal/.config"
  "yazi/.config"
  "zsh/.zcompdump"
  "zsh/.zshenv"
  "zsh/.zsh_history"
  "zsh/.zshrc"
)

for item in "${items[@]}"; do
  package=$(dirname "$item")
  dotfile=$(basename "$item")

  # Convert .foo to dot-foo
  newname="dot-${dotfile#.}"

  if [ -e "$package/$dotfile" ]; then
    echo "Renaming: $package/$dotfile -> $package/$newname"
    mv "$package/$dotfile" "$package/$newname"
  else
    echo "Skipping (not found): $package/$dotfile"
  fi
done

echo ""
echo "Migration complete!"
echo "Next steps:"
echo "1. Update Ansible stow role to add --dotfiles flag"
echo "2. Run stow with --dotfiles to test"
