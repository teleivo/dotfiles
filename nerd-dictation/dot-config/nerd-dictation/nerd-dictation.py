#!/usr/bin/env python3
"""
nerd-dictation configuration for technical terms and word replacements
"""


def nerd_dictation_process(text):
    """
    Process dictated text and replace commonly misheard technical terms
    """
    replacements = {
        # Window manager/compositor terms
        "way bar": "waybar",
        "way var": "waybar",
        "s way": "sway",
        # Configuration files and directories
        "dot config": ".config",
        "dot file": "dotfile",
        "dot files": "dotfiles",
        "y a m l": "yaml",
        "neo vim": "neovim",
        # Shell and terminal terms
        "z shell": "zsh",
        # File formats and extensions
        "jason": "JSON",
        "j s o n": "JSON",
        "mark down": "markdown",
        # Wayland/X11 terms
        "way land": "Wayland",
        "x eleven": "X11",
        # System terms
        "system c t l": "systemctl",
    }

    # Apply replacements (case-insensitive)
    processed_text = text
    for wrong, correct in replacements.items():
        # Replace both lowercase and title case versions
        processed_text = processed_text.replace(wrong, correct)
        processed_text = processed_text.replace(wrong.title(), correct)

    return processed_text
