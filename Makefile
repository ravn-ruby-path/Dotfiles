# NixOS Management Makefile
# Place this in your flake directory (where flake.nix is located)

# Default target
.DEFAULT_GOAL := help

# Configuration
FLAKE_DIR := .
HOSTNAME ?= hydenix
AVAILABLE_HOSTS := hydenix laptop vm

# Nix Performance Options
NIX_OPTS := \
	--option download-buffer-size 5245245245 \
	--option http-connections 16 \
	--option cores 0 \
	--option max-jobs auto

# Colors for pretty output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[0;33m
BLUE := \033[0;34m
PURPLE := \033[0;35m
CYAN := \033[0;36m
NC := \033[0m # No Color

# Include modules (maintain this exact order)
include make/docs.mk
