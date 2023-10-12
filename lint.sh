#!/bin/bash

echo "Running shellcheck"
shellcheck ./*.sh

echo "Running editorconfig-checker"
"$HOME/.local/bin/ec" -exclude "\\.git"

echo "Running hadolint"
hadolint Dockerfile
