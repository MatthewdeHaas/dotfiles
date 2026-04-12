#!/usr/bin/env bash
set -e

doctl compute droplet delete dotfiles-test --force
echo "Droplet destroyed."
