#!/bin/sh

# Compare the files to <nixpkgs> to see what has been added/altered.

unstable="${1:-0}"

channel=/nix/var/nix/profiles/per-user/root/channels/nixos
if [ "$unstable" -eq 1 -a -d "$HOME/Projects/nix/nixpkgs" ]; then
  unstable=0
  channel=$HOME/Projects/nix/nixpkgs
fi
for i in $(find . -mindepth 1 ! -type d ! -path ./default.nix); do
  if [ -e "$channel/pkgs/development/compilers/$i" ]; then
    if [ "$unstable" -eq 1 ]; then
      git --no-pager diff --no-index "$i" "$channel/pkgs/development/compilers/$i"
    else
      git --no-pager diff --no-index "$channel/pkgs/development/compilers/$i" "$i"
    fi
  fi
  if [ -e "$channel/pkgs/build-support/$i" ]; then
    if [ "$unstable" -eq 1 ]; then
      git --no-pager diff --no-index "$i" "$channel/pkgs/build-support/$i"
    else
      git --no-pager diff --no-index "$channel/pkgs/build-support/$i" "$i"
    fi
  fi
done
