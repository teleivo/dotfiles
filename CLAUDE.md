# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a comprehensive personal dotfiles repository for a Linux development environment using Sway (Wayland compositor) and a collection of modern CLI tools. The repository uses Ansible for automated deployment and GNU Stow for symlink management.

## Common Commands

### Initial Setup
```sh
ansible-playbook playbooks/home.yml
```
Run this inside a terminal (not alacritty) to set up the entire dotfiles environment.

### Symlink Management
```sh
ansible-playbook playbooks/stow.yml
```
Creates symlinks for dotfiles using GNU Stow.

### Individual Component Setup
```sh
# Setup specific components
ansible-playbook playbooks/nvim.yml    # Neovim configuration
ansible-playbook playbooks/atuin.yml   # Shell history sync
ansible-playbook playbooks/yazi.yml    # File manager
ansible-playbook playbooks/ghostty.yml # Terminal emulator
```

### Lua Code Formatting
```sh
stylua --check .
stylua .
```
Format Lua code (primarily for Neovim configuration).

### Configuration Validation
```sh
# Validate Sway configuration
sway --validate

# Test Waybar configuration (kill after testing)
waybar --config ~/.config/waybar/config --style ~/.config/waybar/style.css --log-level debug
```
Validate window manager and status bar configurations before applying changes.

## Architecture

### Directory Structure
The repository follows a **stow-compatible structure** where each top-level directory represents a package that will be symlinked:

* `nvim/` - Neovim configuration with lazy.nvim plugin management
* `sway/` - Sway window manager configuration with custom theming
* `waybar/` - Status bar configuration with custom modules
* `zsh/` - Zsh shell configuration and custom functions
* `bin/` - Personal scripts and utilities
* `alias/` - Shell aliases
* `git/` - Git configuration and templates

### Ansible Structure
* `playbooks/` - Main playbook files for different setups
* `playbooks/roles/` - Ansible roles organized by functionality:
  * `base/` - Core system packages and CLI tools installation
  * `stow/` - Symlink creation using GNU Stow
  * `alacritty/`, `ghostty/` - Terminal emulator configurations
  * `vim/`, `zsh/`, `tmux/` - Shell and editor setups

### Key Technologies
* **Stow** - Symlink farm manager for dotfiles deployment
* **Ansible** - Automation for system setup and package installation
* **Sway** - Wayland compositor with extensive customization
* **Neovim** - Text editor with lazy.nvim plugin management
* **Waybar** - Status bar with custom CSS theming

## Configuration Management

### Adding New Dotfiles
1. Create a new directory following stow structure (e.g., `app/.config/app/config`)
2. Add the directory name to the stow command in `playbooks/roles/stow/tasks/main.yml:29-46`
3. If needed, create corresponding config directories in `playbooks/roles/stow/tasks/main.yml:13-19`

### Theming
The repository uses a consistent **Dogrun color scheme** across:
* Sway window manager borders and styling
* Waybar status bar appearance
* Terminal applications color schemes
* Neovim editor theme

Color variables are defined in `sway/.config/sway/config:3-9` and referenced throughout configurations.

### Package Management
System packages are managed through Ansible roles:
* APT packages: `playbooks/roles/base/tasks/main.yml`
* Snap packages: Same file, separate tasks
* Custom installations: Individual task files (e.g., `docker.yml`, `github.yml`)

## Development Workflow

When modifying configurations:
1. Edit files in their respective stow directories
2. Test changes manually if possible like using validation or dry run commands `sway --validate`
3. Run `ansible-playbook playbooks/stow.yml` to update symlinks
4. For system-level changes, run the full `playbooks/home.yml`

The repository includes extensive TODO.md with planned improvements and known issues for reference.
