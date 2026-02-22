#!/bin/bash
# Deploy Windows-side configs (komorebi, yasb) from chezmoi-managed copies
# This runs after `chezmoi apply` to sync configs to the Windows filesystem

WIN_HOME="/mnt/c/Users/write"

# Komorebi configs
cp -u "$HOME/.config/komorebi/komorebi.json" "$WIN_HOME/komorebi.json" 2>/dev/null
cp -u "$HOME/.config/komorebi/komorebi.bar.json" "$WIN_HOME/komorebi.bar.json" 2>/dev/null

# YASB configs
mkdir -p "$WIN_HOME/.config/yasb"
cp -u "$HOME/.config/yasb/config.yaml" "$WIN_HOME/.config/yasb/config.yaml" 2>/dev/null
cp -u "$HOME/.config/yasb/styles.css" "$WIN_HOME/.config/yasb/styles.css" 2>/dev/null
