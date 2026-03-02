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
# Update all flake inputs to their latest versions
upd-all: ## Update all flake inputs
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(CYAN)             🔄 Update All Flake Inputs                 \n$(NC)"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif
	
	@printf "$(GREEN)1.$(NC) $(BLUE)Updating Dependencies:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "$(BLUE)Fetching latest versions for all inputs...$(NC)\n\n"
	nix flake update
	
ifndef EMBEDDED
	@printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(GREEN) ✅ Update complete$(NC)\n"
	@printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif

# ═══════════════════════════════════════════════════════════════
# 📦 UPD-NIXPKGS - Update only the nixpkgs flake input
# ═══════════════════════════════════════════════════════════════
# ──── Targets nixpkgs only to minimize disruption ────────────
upd-nixpkgs: ## Update only nixpkgs input
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(CYAN)             📦 Update Nixpkgs Input                    \n$(NC)"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif
	
	@printf "$(GREEN)1.$(NC) $(BLUE)Updating Nixpkgs:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	nix flake update nixpkgs --flake $(FLAKE_DIR)
	
ifndef EMBEDDED
	@printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(GREEN) ✅ Nixpkgs updated$(NC)\n"
	@printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif

# ═══════════════════════════════════════════════════════════════
# 📦 UPD-HYDENIX - Update only the hydenix flake input
# ═══════════════════════════════════════════════════════════════
# ──── Pulls latest from hydenix upstream only ───────────────
upd-hydenix: ## Update only hydenix input
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(CYAN)             📦 Update Hydenix Input                    \n$(NC)"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif
	
	@printf "$(GREEN)1.$(NC) $(BLUE)Updating Hydenix:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	nix flake update hydenix --flake $(FLAKE_DIR)
	
ifndef EMBEDDED
	@printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(GREEN) ✅ Hydenix updated$(NC)\n"
	@printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif

# ═══════════════════════════════════════════════════════════════
# 🤖 UPD-AI - Update AI tool inputs (opencode, nixpkgs-unstable, llm-agents)
# ═══════════════════════════════════════════════════════════════
# ──── Updates AI inputs then immediately applies configuration ───
# Update OpenCode + Cursor/Antigravity (nixpkgs-unstable) and apply in one go
upd-ai: ## Update OpenCode, Cursor and Antigravity, then apply (update + sys-apply)
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(CYAN)             🤖 Update AI Tools & Apply                 \n$(NC)"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif
	
	@printf "$(GREEN)1.$(NC) $(BLUE)Updating Inputs:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "$(BLUE)Updating opencode, nixpkgs-unstable, llm-agents...$(NC)\n"
	nix flake update --flake $(FLAKE_DIR) opencode nixpkgs-unstable llm-agents
	
	@printf "\n$(GREEN)2.$(NC) $(BLUE)Applying Configuration:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@$(MAKE) --no-print-directory sys-apply
	
ifndef EMBEDDED
	@printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(GREEN) ✅ AI tools update complete$(NC)\n"
	@printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif

# ═══════════════════════════════════════════════════════════════
# 📦 UPD-INPUT - Update a specific named flake input
# ═══════════════════════════════════════════════════════════════
# ──── Requires INPUT=<name>, e.g. make upd-input INPUT=nixpkgs ─
# Allows targeted updates of individual flake dependencies
upd-input: ## Update a specific input (use INPUT=name)
	@if [ -z "$(INPUT)" ]; then \
		printf "\n" ; \
		printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"; \
		printf "$(CYAN)             📦 Update Specific Input                   \n$(NC)"; \
		printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"; \
		printf "\n"; \
		printf "$(RED)❌ Error: Variable INPUT is required$(NC)\n"; \
		printf "\n"; \
		printf "$(YELLOW)Usage: make upd-input INPUT=<name>$(NC)\n"; \
		printf "\n"; \
		printf "$(BLUE)Common inputs:$(NC) nixpkgs, hydenix, nixos-hardware, zen-browser-flake\n"; \
		printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"; \
		printf "\n"; \
		exit 1; \
	fi
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(CYAN)             📦 Update Specific Input                   \n$(NC)"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif
	
	@printf "$(GREEN)1.$(NC) $(BLUE)Updating $(INPUT):$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	nix flake update $(INPUT) --flake $(FLAKE_DIR)
	
ifndef EMBEDDED
	@printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(GREEN) ✅ Input updated$(NC)\n"
	@printf "$(BLUE)Tip: Use 'make upd-diff' to review changes.$(NC)\n"
	@printf "$(YELLOW)Reminder: Run 'make sys-apply' to apply changes.$(NC)\n"
	@printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif

# ═══════════════════════════════════════════════════════════════
# 📊 UPD-DIFF - Show what flake inputs changed in flake.lock
# ═══════════════════════════════════════════════════════════════
# ──── Shows git diff of flake.lock to review version changes ───
# Show intelligent diff showing what inputs changed in flake.lock
upd-diff: ## Show versions differences in flake.lock
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(CYAN)             📊 Flake Changes Analysis                  \n$(NC)"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif
	
	@printf "$(GREEN)1.$(NC) $(BLUE)Lockfile Status:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@HAS_LOCK_CHANGES=$(git diff --quiet flake.lock && echo "no" || echo "yes"); \
	if [ "$$HAS_LOCK_CHANGES" = "no" ]; then \
		printf "$(GREEN)✓ No uncommitted changes in flake.lock$(NC)\n"; \
		printf "$(BLUE)Tip: Run 'make upd-all' to update flake inputs$(NC)\n"; \
ifndef EMBEDDED
		printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"; \
		printf "$(GREEN) ✅ Analysis complete$(NC)\n"; \
		printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"; \
		printf "\n"; \
endif
	else \
		printf "$(YELLOW)⚠️  Changes detected in flake.lock:$(NC)\n\n"; \
		git diff flake.lock; \
ifndef EMBEDDED
		printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"; \
		printf "$(GREEN) ✅ Changes displayed$(NC)\n"; \
		printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"; \
		printf "\n"; \
endif
	fi

# ═══════════════════════════════════════════════════════════════
# 🚀 UPD-UPGRADE - Full upgrade: sync submodules + update flakes + apply
# ═══════════════════════════════════════════════════════════════
# ──── Runs .upd-externals → upd-all → sys-apply-safe in sequence ───
# Complete upgrade workflow: sync everything and apply
upd-upgrade: ## [MASTER] Update EVERYTHING (Submodules + Flakes + Apply)
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(CYAN)             🚀 Master Upgrade (Total Sync)             \n$(NC)"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif
	
	@$(MAKE) --no-print-directory .upd-externals
	@$(MAKE) --no-print-directory upd-all
	@$(MAKE) --no-print-directory sys-apply-safe
	
ifndef EMBEDDED
	@printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(GREEN) ✅ System upgraded successfully$(NC)\n"
	@printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif

# ═══════════════════════════════════════════════════════════════
# 📄 UPD-SHOW - Display all available flake outputs and metadata
# ═══════════════════════════════════════════════════════════════
# ──── Runs 'nix flake show' and filters warnings ────────────
# Display all available outputs from the flake
upd-show: ## Show flake outputs and metadata
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(CYAN)             📄 Flake Outputs Structure                 \n$(NC)"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif
	
	@printf "$(GREEN)1.$(NC) $(BLUE)Outputs:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@nix flake show $(FLAKE_DIR) 2>&1 | grep -v "^warning:" || nix flake show $(FLAKE_DIR) 2>/dev/null || true
	
ifndef EMBEDDED
	@printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(GREEN) ✅ Show complete$(NC)\n"
	@printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif

# ═══════════════════════════════════════════════════════════════
# 📋 UPD-CHECK - Validate flake syntax and structure without building
# ═══════════════════════════════════════════════════════════════
# ──── Runs 'nix flake check' — no system changes applied ─────
# Validate flake syntax and structure without building
upd-check: ## Check flake consistency
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(CYAN)             📋 Check Flake Consistency                 \n$(NC)"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif
	
	@printf "$(GREEN)1.$(NC) $(BLUE)Integrity Check:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "$(BLUE)Running nix flake check...$(NC)\n"
	nix flake check $(FLAKE_DIR)
	
ifndef EMBEDDED
	@printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(GREEN) ✅ Check complete$(NC)\n"
	@printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif
# Update dotfiles submodules and sync configs
upd-dots: .upd-externals ## Update submodules and sync oh-my-tmux

# === Internal Targets ===
# ──── Internal: Called by upd-dots and upd-upgrade to sync externals ───
.upd-externals:
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(CYAN)             🔄 Sync External Configurations            \n$(NC)"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif
	
	@printf "$(GREEN)1.$(NC) $(BLUE)Syncing:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@./make/sync-externals.sh
	
ifndef EMBEDDED
	@printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(GREEN) ✅ Sync complete$(NC)\n"
	@printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif
