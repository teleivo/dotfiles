# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a comprehensive personal dotfiles repository for a Linux development environment using Sway (Wayland compositor) and a collection of modern CLI tools. The repository uses Ansible for automated deployment and GNU Stow for symlink management.

**⚠️ IMPORTANT: All software installation must be managed through Ansible. Do not install tools manually - update the appropriate Ansible role instead. All software versions except APT packages must be pinned to specific versions, checksums verified for downloads, and GPG fingerprints verified for repository keys to ensure reproducibility and security. Ansible scripts must be idempotent - safe to run multiple times without unintended side effects.**

## Documentation Lookup

When looking up documentation for CLI tools and system utilities, **always prefer local man pages first** before using web searches:

* Use `man <command>` to read comprehensive documentation
* Use `man -k <keyword>` to search for related commands
* Use `<command> --help` for quick reference
* Only use WebFetch/WebSearch if the tool lacks man pages or for supplementary information

Example: For mako configuration options, use `man mako` or `man mako.5` instead of web searches.

## Common Commands

### Initial Setup
```sh
cd ansible && ansible-playbook playbooks/home.yml
```
Run this inside a terminal (not alacritty) to set up the entire dotfiles environment.

### Individual Component Setup
```sh
# Setup specific components using tags
cd ansible && ansible-playbook playbooks/home.yml --tags vim      # Neovim configuration
cd ansible && ansible-playbook playbooks/home.yml --tags atuin    # Shell history sync
cd ansible && ansible-playbook playbooks/home.yml --tags base     # Core packages (includes yazi)
cd ansible && ansible-playbook playbooks/home.yml --tags ghostty  # Terminal emulator
cd ansible && ansible-playbook playbooks/home.yml --tags alacritty # Alternative terminal
cd ansible && ansible-playbook playbooks/home.yml --tags stow     # Symlink management
cd ansible && ansible-playbook playbooks/home.yml --tags zoxide   # Smart directory navigation

# Setup multiple components
cd ansible && ansible-playbook playbooks/home.yml --tags "atuin,alacritty,zoxide"

# Setup everything
cd ansible && ansible-playbook playbooks/home.yml
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

# Apply Sway and Waybar configuration changes
swaymsg reload

# Debug Waybar issues (only when troubleshooting)
waybar --config ~/.config/waybar/config --style ~/.config/waybar/style.css --log-level debug

# Validate Ansible playbook syntax
cd ansible && ansible-playbook playbooks/home.yml --syntax-check

# Validate shell scripts
shellcheck bin/.local/bin/*
```
Use `swaymsg reload` to validate and apply both Sway and Waybar configurations. Only use the debug command when troubleshooting Waybar-specific issues. Use `--syntax-check` to validate Ansible YAML syntax before running playbooks. Use `shellcheck` to validate shell scripts for common issues and best practices.

### Ghostty Terminal Configuration
```sh
# Validate Ghostty configuration
ghostty +validate-config

# Reload Ghostty configuration (send USR1 signal to running instances)
pkill -USR1 ghostty
```
Reference: [Ghostty Configuration Options](https://ghostty.org/docs/config/reference)

### Neovim Configuration
```sh
# Format Lua configuration files
stylua nvim/.config/nvim/

# Read plugin documentation
nvim -c ":help plugin-name"

# List installed plugins and their locations
nvim -c ":Lazy"

# Find plugin source code
ls ~/.local/share/nvim/lazy/
```

Plugin source code is located in `~/.local/share/nvim/lazy/<plugin-name>/`. To understand plugin
behavior, read the source code in `lua/<plugin-name>/` directories. Use `:help <topic>` in
Neovim to access comprehensive help documentation for built-in features and many plugins.

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
