#!/usr/bin/env bash
set -e

SSH_KEY_NAME="gambit-deploy" 

doctl compute droplet create dotfiles-test \
  --image ubuntu-24-04-x64 \
  --size s-1vcpu-1gb \
  --region tor1 \
  --ssh-keys "$(doctl compute ssh-key list --format Name,ID --no-header | grep "$SSH_KEY_NAME" | awk '{print $2}')" \
  --wait

IP=$(doctl compute droplet get dotfiles-test --format PublicIPv4 --no-header)

echo ""
echo "Droplet ready. Connect with:"
echo "  ssh root@$IP"
echo ""
echo "To destroy when done:"
echo "  doctl compute droplet delete dotfiles-test --force"
