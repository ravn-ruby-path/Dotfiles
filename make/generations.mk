# ═══════════════════════════════════════════════════════════════
# ⏰ GENERATION MANAGEMENT - NixOS generation tracking and rollback
# ═══════════════════════════════════════════════════════════════
# 📚 Documentation: docs/src/content/docs/makefile/05-generations.mdx
# 🎯 Purpose: List, diff and rollback NixOS system generations
# ──── Overview: 7 targets for generation management and rollback ─────

.PHONY: gen-list gen-rollback gen-rollback-commit gen-diff gen-diff-current gen-sizes gen-current

# === Generation Management ===

# ═══════════════════════════════════════════════════════════════
# 📜 GEN-LIST - List all system generations with details
# ═══════════════════════════════════════════════════════════════
# ──── Reads from /nix/var/nix/profiles/system ─────────────────
# List all system generations with details
gen-list: ## List all system generations
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(CYAN)             📜 System Generations                      \n$(NC)"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif
	
	@printf "$(GREEN)1.$(NC) $(BLUE)Generations List:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
	
ifndef EMBEDDED
	@printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(GREEN) ✅ List complete$(NC)\n"
	@printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif
	@printf "$(YELLOW)📋 Quick Actions:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "• Compare generations: $(BLUE)make gen-diff GEN1=n GEN2=m$(NC)\n"
	@printf "• Rollback:            $(BLUE)make gen-rollback$(NC)\n"
	@printf "\n"

# ═══════════════════════════════════════════════════════════════
# ⏪ GEN-ROLLBACK - Rollback to the previous generation
# ═══════════════════════════════════════════════════════════════
# ──── Prompts for confirmation before executing nixos-rebuild rollback ─
# Rollback to the previous generation
gen-rollback: ## Rollback to previous generation
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(CYAN)             ⏪ System Rollback                         \n$(NC)"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif
	
	@printf "$(GREEN)1.$(NC) $(BLUE)Confirmation:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "$(RED)⚠️  WARNING: You are about to rollback to the previous generation.$(NC)\n"
	@printf "$(YELLOW)This will apply the previous configuration immediately.$(NC)\n"
	@printf "\n"
	@printf "$(RED)Are you sure? Type 'yes' to confirm: $(NC)"; \
	read -r REPLY; \
	if [ "$$REPLY" = "yes" ]; then \
		printf "\n$(YELLOW)Executing rollback...$(NC)\n\n"; \
		sudo nixos-rebuild rollback $(NIX_OPTS); \
		printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"; \
		printf "$(GREEN) ✅ Rollback completed$(NC)\n"; \
		printf "$(BLUE)System restored to previous generation.$(NC)\n"; \
		printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"; \
		printf "\n"; \
	else \
		printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"; \
		printf "$(BLUE)ℹ️  Rollback cancelled$(NC)\n"; \
		printf "$(GREEN)✓ No changes made$(NC)\n"; \
		printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"; \
		printf "\n"; \
	fi

# ═══════════════════════════════════════════════════════════════
# ⏪ GEN-ROLLBACK-COMMIT - Rollback to a specific git commit and rebuild
# ═══════════════════════════════════════════════════════════════
# ──── Requires COMMIT=<hash> — detaches HEAD at that commit ─────
# Rollback to a specific commit and rebuild system
gen-rollback-commit: ## Rollback to specific commit and rebuild (use COMMIT=hash)
	@if [ -z "$$(COMMIT)" ]; then \
		printf "\n"; \
		printf "$(RED)❌ Error: COMMIT parameter is required$(NC)\n"; \
		printf "$(YELLOW)Usage: make gen-rollback-commit COMMIT=<hash>$(NC)\n"; \
		exit 1; \
	fi
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(CYAN)             ⏪ Rollback to Specific Commit             \n$(NC)"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif
	
	@printf "$(GREEN)1.$(NC) $(BLUE)Verifying Commit:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "$(BLUE)Checking commit $(YELLOW)$$(COMMIT)$(BLUE)...$(NC)\n"
	@if ! git rev-parse --verify "$$(COMMIT)" >/dev/null 2>&1; then \
		printf "$(RED)❌ Commit '$$(COMMIT)' not found$(NC)\n"; \
		printf "$(YELLOW)Check git log for correct hash.$(NC)\n\n"; \
		exit 1; \
	fi
	@COMMIT_FULL=$$(git rev-parse "$$(COMMIT)"); \
	COMMIT_SHORT=$$(git rev-parse --short "$$(COMMIT)"); \
	COMMIT_MSG=$$(git log -1 --format="%s" "$$(COMMIT)"); \
	COMMIT_DATE=$$(git log -1 --format="%ci" "$$(COMMIT)"); \
	printf "$(GREEN)✓ Commit found:$(NC)\n"; \
	printf "  $(CYAN)Short Hash:$(NC) $$COMMIT_SHORT\n"; \
	printf "  $(CYAN)Message:   $(NC) $$COMMIT_MSG\n"; \
	printf "  $(CYAN)Date:      $(NC) $$COMMIT_DATE\n\n"; \
	
	@printf "$(GREEN)2.$(NC) $(BLUE)Warning:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "$(RED)⚠️  CRITICAL WARNING:$(NC)\n"
	@printf "$(YELLOW)  • HEAD will be detached at this commit$(NC)\n"
	@printf "$(YELLOW)  • System will be rebuilt from this state$(NC)\n"
	@printf "$(YELLOW)  • Uncommitted changes will be LOST$(NC)\n\n"
	
	@printf "$(RED)Type 'yes' to proceed: $(NC)"; \
	read -r REPLY; \
	if [ "$$REPLY" = "yes" ]; then \
		printf "\n$(GREEN)3.$(NC) $(BLUE)Executing Rollback:$(NC)\n"; \
		printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"; \
		printf "$(YELLOW)Saving current state...$(NC)\n"; \
		CURRENT_BRANCH=$$(git branch --show-current 2>/dev/null || echo "detached"); \
		CURRENT_COMMIT=$$(git rev-parse HEAD); \
		printf "$(YELLOW)Checking out $$COMMIT_SHORT...$(NC)\n"; \
		if git checkout "$$(COMMIT)" >/dev/null 2>&1; then \
			printf "$(GREEN)✓ Checkout successful$(NC)\n"; \
			printf "$(YELLOW)Rebuilding system...$(NC)\n"; \
			if $(MAKE) --no-print-directory sys-apply-core; then \
				printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"; \
				printf "$(GREEN) ✅ Rollback successful$(NC)\n"; \
				printf "$(BLUE)System rebuilt from commit: $$COMMIT_SHORT$(NC)\n"; \
				printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"; \
				printf "\n$(YELLOW)Note:$(NC) Repository is now in detached HEAD state at $$COMMIT_SHORT\n"; \
				printf "$(YELLOW)To return to main:$(NC) git checkout main\n\n"; \
			else \
				printf "\n$(RED)❌ Rebuild failed$(NC)\n"; \
				printf "$(YELLOW)Reverting to previous state...$(NC)\n"; \
				git checkout "$$CURRENT_COMMIT" >/dev/null 2>&1; \
				if [ "$$CURRENT_BRANCH" != "detached" ]; then \
					git checkout "$$CURRENT_BRANCH" >/dev/null 2>&1; \
				fi; \
				printf "$(BLUE)Repository restored$(NC)\n\n"; \
				exit 1; \
			fi; \
		else \
			printf "$(RED)❌ Checkout failed$(NC)\n"; \
			printf "$(YELLOW)Check for uncommitted changes (git status)$(NC)\n\n"; \
			exit 1; \
		fi; \
	else \
		printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"; \
		printf "$(BLUE)ℹ️  Rollback cancelled$(NC)\n"; \
		printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"; \
		printf "\n"; \
	fi

# ═══════════════════════════════════════════════════════════════
# 📊 GEN-DIFF - Compare any two generations
# ═══════════════════════════════════════════════════════════════
# ──── Requires GEN1=n GEN2=m — uses nix-diff ─────────────────
# Compare any two generations (requires GEN1 and GEN2 variables)
gen-diff: ## Compare two generations (use GEN1=n GEN2=m)
	@if [ -z "$$(GEN1)" ] || [ -z "$$(GEN2)" ]; then \
		printf "\n"; \
		printf "$(RED)❌ Error: GEN1 and GEN2 parameters required$(NC)\n"; \
		printf "$(YELLOW)Usage: make gen-diff GEN1=101 GEN2=102$(NC)\n\n"; \
		exit 1; \
	fi
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(CYAN)             📊 Generation Diff (Gen $$(GEN1) vs $$(GEN2))      \n$(NC)"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif
	
	@printf "$(GREEN)1.$(NC) $(BLUE)Comparing Packages:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@nix-diff /nix/var/nix/profiles/system-$$(GEN1)-link /nix/var/nix/profiles/system-$$(GEN2)-link
	
ifndef EMBEDDED
	@printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(GREEN) ✅ Diff complete$(NC)\n"
	@printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif

# ═══════════════════════════════════════════════════════════════
# 📊 GEN-DIFF-CURRENT - Compare current generation with the previous one
# ═══════════════════════════════════════════════════════════════
# ──── Auto-detects current generation number ────────────────
# Compare current generation with the previous one
gen-diff-current: ## Compare current generation with previous
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(CYAN)             📊 Current vs Previous Generation          \n$(NC)"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif
	
	@printf "$(GREEN)1.$(NC) $(BLUE)Identifying Generations:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@CURRENT=$$(sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | grep current | awk '{print $$1}'); \
	PREVIOUS=$$((CURRENT - 1)); \
	if [ $$PREVIOUS -gt 0 ]; then \
		printf "$(BLUE)Comparing Gen $$PREVIOUS (previous) vs Gen $$CURRENT (current)...$(NC)\n\n"; \
		nix-diff /nix/var/nix/profiles/system-$$PREVIOUS-link /nix/var/nix/profiles/system-$$CURRENT-link; \
	else \
		printf "$(YELLOW)No previous generation found.$(NC)\n"; \
	fi
	
ifndef EMBEDDED
	@printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(GREEN) ✅ Diff complete$(NC)\n"
	@printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif

# ═══════════════════════════════════════════════════════════════
# 💾 GEN-SIZES - Show disk usage for all generations
# ═══════════════════════════════════════════════════════════════
# ──── Reports 'du -sh' size for each system generation link ────
# Show disk usage for all generations
gen-sizes: ## Show size of generations
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(CYAN)             💾 Generations Size Report                 \n$(NC)"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif
	
	@printf "$(GREEN)1.$(NC) $(BLUE)Size Analysis:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | \
	awk '{print $$1}' | while read -r gen; do \
		SIZE=$$(du -sh /nix/var/nix/profiles/system-$$gen-link 2>/dev/null | awk '{print $$1}'); \
		printf "  Gen %-4s: %s\n" "$$gen" "$$SIZE"; \
	done
	
ifndef EMBEDDED
	@printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(GREEN) ✅ Report complete$(NC)\n"
	@printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif

# ═══════════════════════════════════════════════════════════════
# 📌 GEN-CURRENT - Show details of the active generation
# ═══════════════════════════════════════════════════════════════
# ──── Filters nix-env generation list for 'current' marker ─────
# Show details of the current generation
gen-current: ## Show current generation info
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(CYAN)             📌 Current Generation Info                 \n$(NC)"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif
	
	@printf "$(GREEN)1.$(NC) $(BLUE)Active Generation:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | grep current
	
ifndef EMBEDDED
	@printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(GREEN) ✅ Info complete$(NC)\n"
	@printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif
