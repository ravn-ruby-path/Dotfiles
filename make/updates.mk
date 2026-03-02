# ═══════════════════════════════════════════════════════════════
# 🔃 UPDATES AND FLAKES - Flake input management and version control
# ═══════════════════════════════════════════════════════════════
# 📚 Documentation: docs/src/content/docs/makefile/04-updates.mdx
# 🎯 Purpose: Update flake inputs, show diff and run full upgrade workflow
# ──── Overview: 10 targets for flake and submodule updates ────────
#
# 🧪 Dry Run (preview without executing):
#    make upd-all         DRY_RUN=1   · skip nix flake update
#    make upd-nixpkgs     DRY_RUN=1   · skip nix flake update nixpkgs
#    make upd-hydenix     DRY_RUN=1   · skip nix flake update hydenix
#    make upd-input       DRY_RUN=1   · skip nix flake update INPUT=...
#    make upd-ai          DRY_RUN=1   · skip update + sys-apply
#    make upd-upgrade     DRY_RUN=1   · skip full upgrade sequence
#    (upd-diff, upd-show, upd-check are read-only)

.PHONY: upd-all upd-nixpkgs upd-hydenix upd-input upd-ai upd-diff upd-upgrade upd-show upd-check upd-dots .upd-externals

DRY_RUN ?= 0
export DRY_RUN
ifeq ($(DRY_RUN),1)
  EXEC = echo "  ▶ [dry-run]"
else
  EXEC =
endif

# === Flake Update ===

# ═══════════════════════════════════════════════════════════════
# 🔄 UPD-ALL - Update all flake inputs to their latest versions
# ═══════════════════════════════════════════════════════════════
# ──── Runs 'nix flake update' in FLAKE_DIR ──────────────────
upd-all: ## Update all flake inputs
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)🔄 upd-all · update all flake inputs$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
endif
	@printf "  fetching latest versions for all inputs...\n"
	@$(EXEC) nix flake update
ifndef EMBEDDED
	@printf "\n$(GREEN)  ✓ done$(NC)\n"
endif
	@printf "\n$(YELLOW)📋 Quick Actions:$(NC)\n"
	@printf "$(DIM)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "  • review changes: $(BLUE)make upd-diff$(NC)\n"
	@printf "  • apply to system: $(BLUE)make sys-apply$(NC)\n\n"

# ═══════════════════════════════════════════════════════════════
# 📦 UPD-NIXPKGS - Update only the nixpkgs flake input
# ═══════════════════════════════════════════════════════════════
# ──── Targets nixpkgs only to minimize disruption ────────────
upd-nixpkgs: ## Update only nixpkgs input
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)📦 upd-nixpkgs · update only nixpkgs$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
endif
	@printf "  targeting nixpkgs only to minimize disruption...\n"
	@$(EXEC) nix flake update nixpkgs --flake $(FLAKE_DIR)
ifndef EMBEDDED
	@printf "\n$(GREEN)  ✓ done$(NC)\n"
endif
	@printf "\n$(YELLOW)📋 Quick Actions:$(NC)\n"
	@printf "$(DIM)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "  • review changes: $(BLUE)make upd-diff$(NC)\n"
	@printf "  • apply to system: $(BLUE)make sys-apply$(NC)\n\n"

# ═══════════════════════════════════════════════════════════════
# 📦 UPD-HYDENIX - Update only the hydenix flake input
# ═══════════════════════════════════════════════════════════════
# ──── Pulls latest from hydenix upstream only ───────────────
upd-hydenix: ## Update only hydenix input
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)📦 upd-hydenix · update only hydenix$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
endif
	@printf "  pulling latest from hydenix upstream...\n"
	@$(EXEC) nix flake update hydenix --flake $(FLAKE_DIR)
ifndef EMBEDDED
	@printf "\n$(GREEN)  ✓ done$(NC)\n"
endif
	@printf "\n$(YELLOW)📋 Quick Actions:$(NC)\n"
	@printf "$(DIM)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "  • review changes: $(BLUE)make upd-diff$(NC)\n"
	@printf "  • apply to system: $(BLUE)make sys-apply$(NC)\n\n"

# ═══════════════════════════════════════════════════════════════
# 🤖 UPD-AI - Update AI tool inputs (opencode, nixpkgs-unstable, llm-agents)
# ═══════════════════════════════════════════════════════════════
# ──── Updates AI inputs then immediately applies configuration ───
upd-ai: ## Update OpenCode, Cursor and Antigravity, then apply (update + sys-apply)
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)🤖 upd-ai · update ai tools and apply$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
endif
	@printf "  updating opencode, nixpkgs-unstable, llm-agents...\n"
	@$(EXEC) nix flake update --flake $(FLAKE_DIR) opencode nixpkgs-unstable llm-agents
	@$(MAKE) --no-print-directory EMBEDDED=1 sys-apply
ifndef EMBEDDED
	@printf "\n$(GREEN)  ✓ done$(NC)\n"
endif
	@printf "\n$(YELLOW)📋 Quick Actions:$(NC)\n"
	@printf "$(DIM)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "  • check current generation: $(BLUE)make gen-current$(NC)\n"
	@printf "  • view error logs: $(BLUE)make log-err$(NC)\n\n"

# ═══════════════════════════════════════════════════════════════
# 📦 UPD-INPUT - Update a specific named flake input
# ═══════════════════════════════════════════════════════════════
# ──── Requires INPUT=<name>, e.g. make upd-input INPUT=nixpkgs ─
upd-input: ## Update a specific input (use INPUT=name)
	@if [ -z "$(INPUT)" ] && [ "$(DRY_RUN)" != "1" ]; then \
		printf "$(RED)  ✗ INPUT is required$(NC)\n"; \
		printf "  usage: make upd-input INPUT=<name>\n"; \
		printf "$(DIM)  common inputs: nixpkgs, hydenix, nixos-hardware, zen-browser-flake$(NC)\n\n"; \
		exit 1; \
	fi
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)📦 upd-input · update $(or $(INPUT),[input-name])$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
endif
	@printf "  updating $(or $(INPUT),[input-name])...\n"
	@$(EXEC) nix flake update $(or $(INPUT),[input-name]) --flake $(FLAKE_DIR)
ifndef EMBEDDED
	@printf "\n$(GREEN)  ✓ done$(NC)\n"
endif
	@printf "\n$(YELLOW)📋 Quick Actions:$(NC)\n"
	@printf "$(DIM)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "  • review changes: $(BLUE)make upd-diff$(NC)\n"
	@printf "  • apply to system: $(BLUE)make sys-apply$(NC)\n\n"

# ═══════════════════════════════════════════════════════════════
# 📊 UPD-DIFF - Show what flake inputs changed in flake.lock
# ═══════════════════════════════════════════════════════════════
# ──── Shows git diff of flake.lock to review version changes ───
upd-diff: ## Show versions differences in flake.lock
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)📊 upd-diff · flake.lock changes$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
endif
	@if git diff --quiet flake.lock 2>/dev/null; then \
		printf "  no uncommitted changes in flake.lock\n"; \
	else \
		printf "$(YELLOW)  ⚠  changes detected in flake.lock:$(NC)\n\n"; \
		git diff flake.lock; \
	fi
ifndef EMBEDDED
	@printf "\n$(GREEN)  ✓ done$(NC)\n"
endif
	@printf "\n$(YELLOW)📋 Quick Actions:$(NC)\n"
	@printf "$(DIM)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "  • update all inputs: $(BLUE)make upd-all$(NC)\n"
	@printf "  • apply to system: $(BLUE)make sys-apply$(NC)\n\n"

# ═══════════════════════════════════════════════════════════════
# 🚀 UPD-UPGRADE - Full upgrade: sync submodules + update flakes + apply
# ═══════════════════════════════════════════════════════════════
# ──── Runs .upd-externals → upd-all → sys-apply-safe in sequence ───
upd-upgrade: ## [MASTER] Update EVERYTHING (Submodules + Flakes + Apply)
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)🚀 upd-upgrade · full upgrade (submodules + flakes + apply)$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
endif
	@$(MAKE) --no-print-directory EMBEDDED=1 .upd-externals
	@$(MAKE) --no-print-directory EMBEDDED=1 upd-all
	@$(MAKE) --no-print-directory EMBEDDED=1 sys-apply-safe
ifndef EMBEDDED
	@printf "\n$(GREEN)  ✓ done$(NC)\n"
endif
	@printf "\n$(YELLOW)📋 Quick Actions:$(NC)\n"
	@printf "$(DIM)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "  • check current generation: $(BLUE)make gen-current$(NC)\n"
	@printf "  • view error logs: $(BLUE)make log-err$(NC)\n\n"

# ═══════════════════════════════════════════════════════════════
# 📄 UPD-SHOW - Display all available flake outputs and metadata
# ═══════════════════════════════════════════════════════════════
# ──── Runs 'nix flake show' and filters warnings ────────────
upd-show: ## Show flake outputs and metadata
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)📄 upd-show · flake outputs and metadata$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
endif
	@nix flake show $(FLAKE_DIR) 2>&1 | grep -v "^warning:" || nix flake show $(FLAKE_DIR) 2>/dev/null || true
ifndef EMBEDDED
	@printf "\n$(GREEN)  ✓ done$(NC)\n"
endif
	@printf "\n$(YELLOW)📋 Quick Actions:$(NC)\n"
	@printf "$(DIM)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "  • update all inputs: $(BLUE)make upd-all$(NC)\n"
	@printf "  • check flake: $(BLUE)make upd-check$(NC)\n\n"

# ═══════════════════════════════════════════════════════════════
# 📋 UPD-CHECK - Validate flake syntax and structure without building
# ═══════════════════════════════════════════════════════════════
# ──── Runs 'nix flake check' — no system changes applied ─────
upd-check: ## Check flake consistency
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)📋 upd-check · validate flake syntax$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
endif
	@printf "  running nix flake check...\n"
	@nix flake check $(FLAKE_DIR)
ifndef EMBEDDED
	@printf "\n$(GREEN)  ✓ done$(NC)\n"
endif
	@printf "\n$(YELLOW)📋 Quick Actions:$(NC)\n"
	@printf "$(DIM)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "  • show flake outputs: $(BLUE)make upd-show$(NC)\n"
	@printf "  • apply to system: $(BLUE)make sys-apply$(NC)\n\n"
# Update dotfiles submodules and sync configs
upd-dots: .upd-externals ## Update submodules and sync oh-my-tmux

# === Internal Targets ===
# ──── Internal: Called by upd-dots and upd-upgrade to sync externals ───
.upd-externals:
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)🔄 .upd-externals · sync external configurations$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
endif
	@printf "  syncing external configs...\n"
	@./make/sync-externals.sh
ifndef EMBEDDED
	@printf "\n$(GREEN)  ✓ done$(NC)\n"
endif
	@printf "\n$(YELLOW)📋 Quick Actions:$(NC)\n"
	@printf "$(DIM)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "  • update all flake inputs: $(BLUE)make upd-all$(NC)\n"
	@printf "  • apply to system: $(BLUE)make sys-apply$(NC)\n\n"
