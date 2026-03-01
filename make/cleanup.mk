# ============================================================================
# Cleanup and Optimization
# ============================================================================
# Description: Targets for cleaning old generations and optimizing the store
# Documentation: docs/src/content/docs/makefile/03-cleanup.mdx
# Targets: 5 targets
# ============================================================================

.PHONY: sys-gc sys-purge sys-optimize sys-clean-result sys-fix-store

# === Mantenimiento y Espacio ===

# Flexible cleanup - removes generations older than specified days (default: 30)
# Usage: make sys-gc [DAYS=n]
DAYS ?= 30
sys-gc: ## Clean build artifacts older than specified days (default: 30)
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@if [ "$(DAYS)" -eq 7 ]; then \
		printf "$(CYAN)             🧹 Weekly Cleanup (7 Days)                 \n$(NC)"; \
	elif [ "$(DAYS)" -eq 30 ]; then \
		printf "$(CYAN)             🧹 Standard Cleanup (30 Days)              \n$(NC)"; \
	elif [ "$(DAYS)" -eq 90 ]; then \
		printf "$(CYAN)             🧹 Conservative Cleanup (90 Days)          \n$(NC)"; \
	else \
		printf "$(CYAN)             🧹 System Cleanup ($(DAYS) Days)                  \n$(NC)"; \
	fi
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif

	@printf "$(GREEN)1.$(NC) $(BLUE)Analyzing Garbage Collection:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "$(BLUE)Removing build artifacts older than $(DAYS) days...$(NC)\n"
	@if [ "$(DAYS)" -lt 15 ]; then \
		printf "$(YELLOW)⚠️  Warning: Only keeping $(DAYS) days of rollback history.\n$(NC)"; \
	else \
		printf "$(BLUE)Generations from the last $(DAYS) days will be kept.\n$(NC)"; \
	fi
	
	@printf "\n$(GREEN)2.$(NC) $(BLUE)Running Garbage Collector:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@sudo nix-collect-garbage --delete-older-than $(DAYS)d
	@nix-collect-garbage --delete-older-than $(DAYS)d
	
ifndef EMBEDDED
	@printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(GREEN) ✅ Cleanup completed (kept last $(DAYS) days)$(NC)\n"
	@printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif
	@printf "$(YELLOW)📋 Quick Actions:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "• Check space:       $(BLUE)make sys-status$(NC)\n"
	@printf "• Optimize store:    $(BLUE)make sys-optimize$(NC)\n"
	@printf "\n"


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
	else \
		printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"; \
		printf "$(BLUE)ℹ️  Deep purge cancelled$(NC)\n"; \
		printf "$(GREEN)✓ No changes were made to the system$(NC)\n"; \
		printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"; \
		printf "\n"; \
	fi

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
	@sudo nix-store --optimise
	
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
		find . -maxdepth 2 -name 'result*' -type l -delete 2>/dev/null; \
		printf "$(GREEN)✅ Removed $$COUNT symlink(s)$(NC)\n"; \
	fi
	
ifndef EMBEDDED
	@printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(GREEN) ✅ Cleanup completed$(NC)\n"
	@printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif

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
	@if nix-store --verify --check-contents --repair; then \
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
