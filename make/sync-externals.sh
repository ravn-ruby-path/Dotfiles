#!/run/current-system/sw/bin/bash
# make/sync-externals.sh
# Documentation: docs/src/content/docs/makefile/04-updates.mdx
# Purpose: Sync git submodules and copy oh-my-tmux configuration
# Usage: Called internally by 'make upd-dots' and 'make upd-upgrade'

set -euo pipefail

# ═══════════════════════════════════════════════════════════════
# 🎨 OUTPUT HELPERS - Color variables for formatted output
# ═══════════════════════════════════════════════════════════════
CYAN='\033[0;36m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

# ═══════════════════════════════════════════════════════════════
# 📁 PATH SETUP - Locate repository root relative to this script
# ═══════════════════════════════════════════════════════════════
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT_DIR"

FLAKE_DIR="."

printf "${CYAN}═════════════════════════════════════════════════════════════════════════════════${NC}\n"
printf "${CYAN}            🔄 Dotfiles Automatic Update                   ${NC}\n"
printf "${CYAN}═════════════════════════════════════════════════════════════════════════════════${NC}\n"

# ──── Step 1: Update Submodules ───────────────────────────────────────────────
printf "\n${BLUE}🔄 Updating git submodules...${NC}\n"
git submodule update --init --recursive --remote
printf "${GREEN}✓ Submodules updated${NC}\n"

# ──── Step 2: Sync oh-my-tmux.conf ─────────────────────────────────────────────
printf "\n${BLUE}⌨️ Syncing oh-my-tmux.conf...${NC}\n"
if [ -f "modules/hm/programs/terminal/oh-my-tmux/.tmux.conf" ]; then
    cp modules/hm/programs/terminal/oh-my-tmux/.tmux.conf modules/hm/programs/terminal/oh-my-tmux.conf
    printf "${GREEN}✓ oh-my-tmux.conf synced${NC}\n"
else
    printf "${RED}✗ Error: oh-my-tmux file not found${NC}\n"
    exit 1
fi

printf "\n${GREEN}✅ External sync completed${NC}\n"
printf "${CYAN}═════════════════════════════════════════════════════════════════════════════════${NC}\n\n"
