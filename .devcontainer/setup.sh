#!/usr/bin/env bash

LAZYGIT_URL="https://github.com/jesseduffield/lazygit/releases/download/v0.43.1/lazygit_0.43.1_Linux_x86_64.tar.gz"

export PATH=$PATH:~/.local/bin/lazygit

# Start starship prompt
echo 'starship init fish | source' >> /home/vscode/.config/fish/config.fish

# Create the necessary directories
mkdir -p ~/.local/bin
mkdir -p /tmp/lazygit

# Download and extract lazygit
wget -qO - ${LAZYGIT_URL} | tar -zx -C /tmp/lazygit

# Make the binary executable
chmod +x /tmp/lazygit/lazygit

# Move the binary to ~/.local/bin
mv /tmp/lazygit/lazygit ~/.local/bin

# Clean up
rm -rf /tmp/lazygit

# run nextflow once to get the files
nextflow
