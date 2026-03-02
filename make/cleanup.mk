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
	@printf "  · $(BLUE) make sys-status   $(NC)$(DIM) check disk usage$(NC)\n"
	@printf "  · $(BLUE) make sys-optimize $(NC)$(DIM) deduplicate nix store$(NC)\n\n"


# ═══════════════════════════════════════════════════════════════
# 🗑️  SYS-PURGE - Remove ALL old generations (IRREVERSIBLE)
# ═══════════════════════════════════════════════════════════════
# ──── Deep Purge: Requires typed confirmation; no rollback possible ─
# Deep clean - removes ALL old generations (IRREVERSIBLE!)
# Use with extreme caution - requires confirmation
sys-purge: ## Aggressive cleanup (removes ALL old generations)
ifndef EMBEDDED
	@printf "\n"
	@printf "$(RED)🗑️  sys-purge · irreversible$(NC)\n"
	@printf "$(RED)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
endif
	@printf "$(RED)  ⚠  deletes ALL old generations — no rollback possible$(NC)\n"
	@printf "\n"
	@printf "$(YELLOW)  what gets deleted:$(NC)\n"
	@printf "$(DIM)    · all system generations (except current)\n"
	@printf "    · all user generations\n"
	@printf "    · all unreferenced packages$(NC)\n"
	@printf "\n"
	@printf "$(RED)  type 'yes' to continue: $(NC)"; \
	read -r REPLY; \
	if [ "$$REPLY" = "yes" ]; then \
		if [ "$$DRY_RUN" = "1" ]; then \
			printf "\n$(YELLOW)  ▶ [dry-run] Would execute:$(NC)\n"; \
			printf "$(DIM)      sudo nix-collect-garbage -d\n"; \
			printf "      nix-collect-garbage -d\n"; \
			printf "      make sys-optimize\n"; \
			printf "      make sys-disk$(NC)\n"; \
		else \
			printf "\n  purging...\n\n"; \
			sudo nix-collect-garbage -d; \
			nix-collect-garbage -d; \
			$(MAKE) --no-print-directory sys-optimize EMBEDDED=1; \
			$(MAKE) --no-print-directory sys-disk EMBEDDED=1; \
			printf "\n$(GREEN)  ✓ done$(NC)\n"; \
		fi; \
		printf "\n$(YELLOW)📋 Quick Actions:$(NC)\n"; \
		printf "$(DIM)────────────────────────────────────────────────────────────────────────────────$(NC)\n"; \
		printf "  · $(BLUE) make sys-status $(NC)$(DIM) check freed disk space$(NC)\n"; \
		printf "  · $(BLUE) make gen-list   $(NC)$(DIM) verify no old generations remain$(NC)\n\n"; \
	else \
		printf "\n$(DIM)  cancelled — no changes made$(NC)\n\n"; \
	fi

# ═══════════════════════════════════════════════════════════════
# 🚀 SYS-OPTIMIZE - Deduplicate store with hardlinks
# ═══════════════════════════════════════════════════════════════
# ──── Optimize: nix-store --optimise; safe, does not delete ──
# Optimize Nix store by creating hardlinks for identical files
sys-optimize: ## Optimize nix store
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)🚀 sys-optimize · deduplicate nix store$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
endif
	@printf "  finds identical files and replaces them with hardlinks\n"
	@printf "$(DIM)  safe — nothing is deleted  ·  may take 5–30 min$(NC)\n"
	@printf "\n"
	@$(EXEC) sudo nix-store --optimise
ifndef EMBEDDED
	@printf "\n$(GREEN)  ✓ done$(NC)\n"
endif
	@printf "\n$(YELLOW)📋 Quick Actions:$(NC)\n"
	@printf "$(DIM)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "  · $(BLUE) make sys-status $(NC)$(DIM) check freed disk space$(NC)\n\n"

# ═══════════════════════════════════════════════════════════════
# 🧹 SYS-CLEAN-RESULT - Remove result symlinks from nix build
# ═══════════════════════════════════════════════════════════════
# ──── Clean Result: Removes result* symlinks left by nix build ─
# Remove result symlinks created by nix build commands
sys-clean-result: ## Remove result symlinks
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)🧹 sys-clean-result · remove nix build symlinks$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
endif
	@RESULT_LINKS=$$(find . -maxdepth 2 -name 'result*' -type l 2>/dev/null); \
	if [ -z "$$RESULT_LINKS" ]; then \
		printf "$(GREEN)  ✓ no result symlinks found$(NC)\n"; \
	else \
		COUNT=$$(echo "$$RESULT_LINKS" | wc -l); \
		printf "  found $(YELLOW)$$COUNT$(NC) symlink(s):\n"; \
		echo "$$RESULT_LINKS" | while read -r link; do \
			TARGET=$$(readlink -f "$$link" 2>/dev/null || echo "broken"); \
			if [ "$$TARGET" != "broken" ]; then \
				printf "  $(DIM)$$link → $$TARGET$(NC)\n"; \
			else \
				printf "  $(RED)$$link → (broken)$(NC)\n"; \
			fi; \
		done; \
		printf "\n"; \
		if [ "$$DRY_RUN" = "1" ]; then \
			printf "  ▶ [dry-run] find . -maxdepth 2 -name 'result*' -type l -delete\n"; \
			printf "$(YELLOW)  would remove $$COUNT symlink(s)$(NC)\n"; \
		else \
			find . -maxdepth 2 -name 'result*' -type l -delete 2>/dev/null; \
			printf "$(GREEN)  ✓ removed $$COUNT symlink(s)$(NC)\n"; \
		fi; \
	fi
ifndef EMBEDDED
	@printf "\n$(GREEN)  ✓ done$(NC)\n"
endif
	@printf "\n$(YELLOW)📋 Quick Actions:$(NC)\n"
	@printf "$(DIM)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "  · $(BLUE) make sys-build $(NC)$(DIM) rebuild to regenerate result symlinks$(NC)\n\n"

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
