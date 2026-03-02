# ═══════════════════════════════════════════════════════════════
# 🧹 CLEANUP AND OPTIMIZATION - Nix store management
# ═══════════════════════════════════════════════════════════════
# 📚 Documentation: docs/src/content/docs/makefile/03-cleanup.mdx
# 🎯 Purpose: Remove old generations, optimize and repair the Nix store
# ──── Overview: 5 targets for store cleanup and optimization ────
#
# 🧪 Dry Run (preview without executing):
#    make sys-gc          DRY_RUN=1
#    make sys-purge       DRY_RUN=1
#    make sys-optimize    DRY_RUN=1
#    make sys-clean-result DRY_RUN=1
#    make sys-fix-store   DRY_RUN=1

.PHONY: sys-gc sys-purge sys-optimize sys-clean-result sys-fix-store

# ──── Dry Run: make <target> DRY_RUN=1 to preview without executing ─
DRY_RUN ?= 0
export DRY_RUN
ifeq ($(DRY_RUN),1)
  EXEC = echo "  ▶ [dry-run]"
else
  EXEC =
endif

# === Maintenance and Optimization ===

# ═══════════════════════════════════════════════════════════════
# 🗑️ SYS-GC - Garbage collect generations older than N days
# ═══════════════════════════════════════════════════════════════
# ──── Flexible cleanup: DAYS=n (default 30), keeps rollback history ─
# Usage: make sys-gc [DAYS=n]
DAYS ?= 30
sys-gc: ## Clean build artifacts older than specified days (default: 30)
ifndef EMBEDDED
	@printf "\n"
	@if [ "$(DAYS)" -eq 7 ]; then \
		printf "$(CYAN)🧹 sys-gc · weekly (7 days)$(NC)\n"; \
	elif [ "$(DAYS)" -eq 30 ]; then \
		printf "$(CYAN)🧹 sys-gc · 30 days$(NC)\n"; \
	elif [ "$(DAYS)" -eq 90 ]; then \
		printf "$(CYAN)🧹 sys-gc · conservative (90 days)$(NC)\n"; \
	else \
		printf "$(CYAN)🧹 sys-gc · $(DAYS) days$(NC)\n"; \
	fi
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
endif
	@if [ "$(DAYS)" -lt 15 ]; then \
		printf "$(YELLOW)  ⚠  keeping only $(DAYS) days — limited rollback history$(NC)\n"; \
	else \
		printf "  Removing build artifacts older than $(DAYS) days...\n"; \
	fi
	@printf "\n"
	@$(EXEC) sudo nix-collect-garbage --delete-older-than $(DAYS)d
	@$(EXEC) nix-collect-garbage --delete-older-than $(DAYS)d
ifndef EMBEDDED
	@printf "\n$(GREEN)  ✓ done$(NC)\n"
endif
	@printf "\n$(YELLOW)📋 Quick Actions:$(NC)\n"
	@printf "$(DIM)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "$(DIM)  ·  make sys-status    check disk usage\n"
	@printf "  ·  make sys-optimize  deduplicate nix store$(NC)\n\n"


# ═══════════════════════════════════════════════════════════════
# 🗑️  SYS-PURGE - Remove ALL old generations (IRREVERSIBLE)
# ═══════════════════════════════════════════════════════════════
# ──── Deep Purge: Requires typed confirmation; no rollback possible ─
# Deep clean - removes ALL old generations (IRREVERSIBLE!)
# Use with extreme caution - requires confirmation
sys-purge: ## Aggressive cleanup (removes ALL old generations)
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(CYAN)             🗑️  Deep Purge (IRREVERSIBLE)                \n$(NC)"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif
	
	@printf "$(GREEN)1.$(NC) $(BLUE)Critical Warning:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "$(RED)⚠️  CRITICAL WARNING ⚠️$(NC)\n"
	@printf "$(RED)This command will delete ALL old generations from the system.$(NC)\n"
	@printf "$(RED)This action is IRREVERSIBLE and you will NOT be able to rollback.$(NC)\n"
	@printf "\n"
	@printf "$(YELLOW)What will be deleted?$(NC)\n"
	@printf "$(YELLOW)  • ALL system generations (except current)$(NC)\n"
	@printf "$(YELLOW)  • ALL user generations$(NC)\n"
	@printf "$(YELLOW)  • ALL unreferenced packages$(NC)\n"
	@printf "\n"
	@printf "$(BLUE)Space to be freed: Maximum possible (typically 20-100+ GB)$(NC)\n"
	@printf "\n"
	
	@printf "$(GREEN)2.$(NC) $(BLUE)Confirmation:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "$(RED)Are you ABSOLUTELY sure? Type 'yes' to continue: $(NC)"; \
	read -r REPLY; \
	if [ "$$REPLY" = "yes" ]; then \
		if [ "$$DRY_RUN" = "1" ]; then \
			printf "\n$(YELLOW)  ▶ [dry-run] Would execute:$(NC)\n"; \
			printf "$(YELLOW)      sudo nix-collect-garbage -d$(NC)\n"; \
			printf "$(YELLOW)      nix-collect-garbage -d$(NC)\n"; \
			printf "$(YELLOW)      make sys-optimize$(NC)\n"; \
			printf "$(YELLOW)      make sys-disk$(NC)\n"; \
		else \
			printf "\n$(YELLOW)Executing deep purge...$(NC)\n\n"; \
			sudo nix-collect-garbage -d; \
			nix-collect-garbage -d; \
			printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"; \
			printf "$(GREEN) ✅ Deep purge completed$(NC)\n"; \
			printf "$(RED)⚠️  ALL old generations have been deleted$(NC)\n"; \
			printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"; \
			printf "\n"; \
			printf "$(YELLOW)Step 2: Auto-Optimizing Nix Store...$(NC)\n"; \
			$(MAKE) sys-optimize; \
			printf "\n$(YELLOW)Step 3: Final Disk Report...$(NC)\n"; \
			$(MAKE) sys-disk; \
		fi; \
	else \
		printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"; \
		printf "$(BLUE)ℹ️  Deep purge cancelled$(NC)\n"; \
		printf "$(GREEN)✓ No changes were made to the system$(NC)\n"; \
		printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"; \
		printf "\n"; \
	fi

# ═══════════════════════════════════════════════════════════════
# 🚀 SYS-OPTIMIZE - Deduplicate store with hardlinks
# ═══════════════════════════════════════════════════════════════
# ──── Optimize: nix-store --optimise; safe, does not delete ──
# Optimize Nix store by creating hardlinks for identical files
sys-optimize: ## Optimize nix store
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(CYAN)             🚀 Optimizing Nix Store                    \n$(NC)"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif
	
	@printf "$(GREEN)1.$(NC) $(BLUE)Optimizing Store:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "$(BLUE)Finding identical files and creating hardlinks...$(NC)\n"
	@printf "$(YELLOW)This saves space without deleting anything - safe process.$(NC)\n"
	@printf "$(YELLOW)⏱️  This may take 5-30 minutes depending on store size.$(NC)\n"
	@printf "\n"
	@$(EXEC) sudo nix-store --optimise
	
ifndef EMBEDDED
	@printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(GREEN) ✅ Store optimization completed$(NC)\n"
	@printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif
	@printf "$(YELLOW)📋 Quick Actions:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "• Check space:       $(BLUE)make sys-status$(NC)\n"
	@printf "\n"

# ═══════════════════════════════════════════════════════════════
# 🧹 SYS-CLEAN-RESULT - Remove result symlinks from nix build
# ═══════════════════════════════════════════════════════════════
# ──── Clean Result: Removes result* symlinks left by nix build ─
# Remove result symlinks created by nix build commands
sys-clean-result: ## Remove result symlinks
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(CYAN)             🧹 Cleaning Result Symlinks                \n$(NC)"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif
	
	@printf "$(GREEN)1.$(NC) $(BLUE)Finding Symlinks:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "$(BLUE)Searching for result symlinks created by Nix builds...$(NC)\n"
	@printf "$(YELLOW)These links can be safely removed.$(NC)\n"
	@printf "\n"
	@RESULT_LINKS=$$(find . -maxdepth 2 -name 'result*' -type l 2>/dev/null); \
	if [ -z "$$RESULT_LINKS" ]; then \
		printf "$(GREEN)✓ No result symlinks found$(NC)\n"; \
	else \
		COUNT=$$(echo "$$RESULT_LINKS" | wc -l); \
		printf "$(BLUE)Found $(YELLOW)$$COUNT$(NC) $(BLUE)result symlink(s):$(NC)\n"; \
		echo "$$RESULT_LINKS" | while read -r link; do \
			TARGET=$$(readlink -f "$$link" 2>/dev/null || echo "broken"); \
			printf "  $(YELLOW)$$link$(NC)"; \
			if [ "$$TARGET" != "broken" ]; then \
				printf " → $(GREEN)$$TARGET$(NC)\n"; \
			else \
				printf " → $(RED)(broken link)$(NC)\n"; \
			fi; \
		done; \
		printf "\n$(GREEN)2.$(NC) $(BLUE)Removing Symlinks:$(NC)\n"; \
		printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"; \
		if [ "$$DRY_RUN" = "1" ]; then \
			printf "  ▶ [dry-run] find . -maxdepth 2 -name 'result*' -type l -delete\n"; \
			printf "$(YELLOW)  Would remove $$COUNT symlink(s)$(NC)\n"; \
		else \
			find . -maxdepth 2 -name 'result*' -type l -delete 2>/dev/null; \
			printf "$(GREEN)✅ Removed $$COUNT symlink(s)$(NC)\n"; \
		fi; \
	fi
	
ifndef EMBEDDED
	@printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(GREEN) ✅ Cleanup completed$(NC)\n"
	@printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif

# ═══════════════════════════════════════════════════════════════
# 🔧 SYS-FIX-STORE - Verify and repair the Nix store for corruption
# ═══════════════════════════════════════════════════════════════
# ──── Repair: --check-contents --repair; slow on large stores ────
# Verify and repair the Nix store for corruption
sys-fix-store: ## Attempt to repair nix store
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(CYAN)             🔧 Repair Nix Store                        \n$(NC)"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif
	
	@printf "$(GREEN)1.$(NC) $(BLUE)Verifying Store:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "$(BLUE)Checking content addressability and repairing corruption...$(NC)\n"
	@printf "$(YELLOW)⚠️  This may take a long time (minutes to hours) on large systems.$(NC)\n"
	@printf "\n"
	@if [ "$(DRY_RUN)" = "1" ]; then \
		printf "  ▶ [dry-run] nix-store --verify --check-contents --repair\n"; \
	elif nix-store --verify --check-contents --repair; then \
		printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"; \
		printf "$(GREEN) ✅ Store repair completed$(NC)\n"; \
		printf "$(BLUE)All store paths verified and repaired.$(NC)\n"; \
		printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"; \
		printf "\n"; \
	else \
		printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"; \
		printf "$(RED) ❌ Store repair encountered errors$(NC)\n"; \
		printf "$(YELLOW)Check the output above for details.$(NC)\n"; \
		printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"; \
		printf "\n"; \
		exit 1; \
	fi
