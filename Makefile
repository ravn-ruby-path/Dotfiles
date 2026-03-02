# ═══════════════════════════════════════════════════════════════
# 🔧 NIXOS MANAGEMENT MAKEFILE - SYSTEM AUTOMATION TOOLKIT
# ═══════════════════════════════════════════════════════════════
# 📚 Documentation: docs/src/content/docs/makefile/
# 🎯 Purpose: Provide comprehensive system management commands for NixOS
# 🔄 Workflow: Build → Test → Deploy with safety checks and monitoring
# Place this in your flake directory (where flake.nix is located)
# ----------------------------------------------------------------------------

# ═══════════════════════════════════════════════════════════════
# 🎯 DEFAULT TARGET - Show help when no target specified
# ═══════════════════════════════════════════════════════════════

.DEFAULT_GOAL := help

# ═══════════════════════════════════════════════════════════════
# ⚙️ CONFIGURATION - Root of the NixOS configuration
# ═══════════════════════════════════════════════════════════════

# ──── Flake Directory: Root of the NixOS configuration ──────
FLAKE_DIR := .

# ──── Hostname: Target system (override with HOSTNAME=host) ──
HOSTNAME ?= hydenix

# ──── Available Hosts: Supported system configurations ──────
AVAILABLE_HOSTS := hydenix laptop vm

# ═══════════════════════════════════════════════════════════════
# 🚀 PERFORMANCE OPTIONS - Optimized build settings for speed
# ═══════════════════════════════════════════════════════════════

NIX_OPTS := \
	--option download-buffer-size 5245245245 \
	--option http-connections 16 \
	--option cores 0 \
	--option max-jobs auto

# ═══════════════════════════════════════════════════════════════
# 🎨 OUTPUT FORMATTING - ANSI color codes for visual feedback
# ═══════════════════════════════════════════════════════════════

RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[0;33m
BLUE := \033[0;34m
PURPLE := \033[0;35m
CYAN := \033[0;36m
NC := \033[0m # No Color

# ═══════════════════════════════════════════════════════════════
# 📦 INCLUDE ORDER - Critical for dependency resolution
# ═══════════════════════════════════════════════════════════════

include make/docs.mk
include make/system.mk
include make/cleanup.mk
include make/updates.mk
include make/generations.mk
include make/git.mk
include make/logs.mk
include make/dev.mk
include make/format.mk
