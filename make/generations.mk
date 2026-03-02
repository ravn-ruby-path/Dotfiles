# ═══════════════════════════════════════════════════════════════
# ⏰ GENERATION MANAGEMENT - NixOS generation tracking and rollback
# ═══════════════════════════════════════════════════════════════
# 📚 Documentation: docs/src/content/docs/makefile/05-generations.mdx
# 🎯 Purpose: List, diff and rollback NixOS system generations
# ──── Overview: 7 targets for generation management and rollback ─────
#
# 🧪 Dry Run (preview without executing):
#    make gen-rollback         DRY_RUN=1   · skip nixos-rebuild switch
#    make gen-rollback-commit  DRY_RUN=1   · skip git checkout + rebuild
#    (gen-list, gen-diff, gen-diff-current, gen-sizes, gen-current are read-only)

.PHONY: gen-list gen-rollback gen-rollback-commit gen-diff gen-diff-current gen-sizes gen-current

DRY_RUN ?= 0
export DRY_RUN
ifeq ($(DRY_RUN),1)
  EXEC = echo "  ▶ [dry-run]"
else
  EXEC =
endif

# === Generation Management ===

# ═══════════════════════════════════════════════════════════════
# 📜 GEN-LIST - List all system generations with details
# ═══════════════════════════════════════════════════════════════
# ──── Reads from /nix/var/nix/profiles/system ─────────────────
gen-list: ## List all system generations
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)📜 gen-list · system generations$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
endif
	@sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
ifndef EMBEDDED
	@printf "\n$(GREEN)  ✓ done$(NC)\n"
endif
	@printf "\n$(YELLOW)📋 Quick Actions:$(NC)\n"
	@printf "$(DIM)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "  • compare generations: $(BLUE)make gen-diff GEN1=n GEN2=m$(NC)\n"
	@printf "  • rollback:            $(BLUE)make gen-rollback$(NC)\n\n"

# ═══════════════════════════════════════════════════════════════
# ⏪ GEN-ROLLBACK - Rollback to the previous generation
# ═══════════════════════════════════════════════════════════════
# ──── Prompts for confirmation before executing nixos-rebuild rollback ─
gen-rollback: ## Rollback to previous generation
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)⏪ gen-rollback · revert to previous generation$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
endif
	@printf "$(RED)  ⚠  rolling back to the previous generation$(NC)\n"
	@printf "$(DIM)  this will apply the previous configuration immediately$(NC)\n\n"
	@printf "$(RED)  type 'yes' to confirm: $(NC)"; \
	read -r REPLY; \
	if [ "$$REPLY" = "yes" ]; then \
		printf "\n$(DIM)  executing rollback...$(NC)\n\n"; \
		if [ "$$DRY_RUN" = "1" ]; then \
			echo "  ▶ [dry-run] sudo nixos-rebuild rollback $(NIX_OPTS)"; \
		else \
			sudo nixos-rebuild rollback $(NIX_OPTS); \
		fi; \
		printf "\n$(GREEN)  ✓ system restored to previous generation$(NC)\n\n"; \
	else \
		printf "\n$(DIM)  rollback cancelled — no changes made$(NC)\n\n"; \
	fi

# ═══════════════════════════════════════════════════════════════
# ⏪ GEN-ROLLBACK-COMMIT - Rollback to a specific git commit and rebuild
# ═══════════════════════════════════════════════════════════════
# ──── Requires COMMIT=<hash> — detaches HEAD at that commit ─────
gen-rollback-commit: ## Rollback to specific commit and rebuild (use COMMIT=hash)
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)⏪ gen-rollback-commit · revert to specific commit$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
endif
	@if [ -z "$(COMMIT)" ]; then \
		printf "$(YELLOW)  usage: make gen-rollback-commit COMMIT=<hash>$(NC)\n\n"; \
	else \
		if ! git rev-parse --verify "$(COMMIT)" >/dev/null 2>&1; then \
			printf "$(RED)  ❌ commit '$(COMMIT)' not found$(NC)\n"; \
			printf "$(DIM)  check git log for the correct hash$(NC)\n\n"; \
		else \
			COMMIT_SHORT=$$(git rev-parse --short "$(COMMIT)"); \
			COMMIT_MSG=$$(git log -1 --format="%s" "$(COMMIT)"); \
			COMMIT_DATE=$$(git log -1 --format="%ci" "$(COMMIT)"); \
			printf "$(GREEN)  ✓ commit found:$(NC)\n"; \
			printf "$(DIM)    hash:    $$COMMIT_SHORT$(NC)\n"; \
			printf "$(DIM)    message: $$COMMIT_MSG$(NC)\n"; \
			printf "$(DIM)    date:    $$COMMIT_DATE$(NC)\n\n"; \
			printf "$(RED)  ⚠  HEAD will be detached · uncommitted changes will be LOST$(NC)\n\n"; \
			printf "$(RED)  type 'yes' to confirm: $(NC)"; \
			read -r REPLY; \
			if [ "$$REPLY" = "yes" ]; then \
				printf "\n$(DIM)  checking out $$COMMIT_SHORT...$(NC)\n"; \
				CURRENT_BRANCH=$$(git branch --show-current 2>/dev/null || echo "detached"); \
				CURRENT_COMMIT=$$(git rev-parse HEAD); \
				if [ "$$DRY_RUN" = "1" ]; then \
					echo "  ▶ [dry-run] git checkout $(COMMIT)"; \
					echo "  ▶ [dry-run] make sys-apply-core"; \
				else \
					if git checkout "$(COMMIT)" >/dev/null 2>&1; then \
						printf "$(DIM)  rebuilding system...$(NC)\n"; \
						if $(MAKE) --no-print-directory sys-apply-core; then \
							printf "\n$(GREEN)  ✓ system rebuilt from commit $$COMMIT_SHORT$(NC)\n"; \
							printf "$(DIM)  repo is in detached HEAD — run: git checkout main$(NC)\n\n"; \
						else \
							printf "\n$(RED)  ❌ rebuild failed — reverting$(NC)\n"; \
							git checkout "$$CURRENT_COMMIT" >/dev/null 2>&1; \
							if [ "$$CURRENT_BRANCH" != "detached" ]; then git checkout "$$CURRENT_BRANCH" >/dev/null 2>&1; fi; \
							printf "$(DIM)  repository restored$(NC)\n\n"; \
						fi; \
					else \
						printf "$(RED)  ❌ checkout failed$(NC)\n"; \
						printf "$(DIM)  check for uncommitted changes: git status$(NC)\n\n"; \
					fi; \
				fi; \
			else \
				printf "\n$(DIM)  rollback cancelled — no changes made$(NC)\n\n"; \
			fi; \
		fi; \
	fi

# ═══════════════════════════════════════════════════════════════
# 📊 GEN-DIFF - Compare any two generations
# ═══════════════════════════════════════════════════════════════
# ──── Requires GEN1=n GEN2=m — uses nix-diff ─────────────────
gen-diff: ## Compare two generations (use GEN1=n GEN2=m)
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)📊 gen-diff · compare two generations$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
endif
	@if [ -z "$(GEN1)" ] || [ -z "$(GEN2)" ]; then \
		printf "$(YELLOW)  usage: make gen-diff GEN1=<n> GEN2=<m>$(NC)\n\n"; \
	elif ! command -v nix-diff >/dev/null 2>&1; then \
		printf "$(YELLOW)  ⚠  nix-diff not found — add it to your packages$(NC)\n"; \
		printf "$(DIM)  nix run nixpkgs#nix-diff -- /nix/var/nix/profiles/system-$(GEN1)-link /nix/var/nix/profiles/system-$(GEN2)-link$(NC)\n\n"; \
	else \
		nix-diff /nix/var/nix/profiles/system-$(GEN1)-link /nix/var/nix/profiles/system-$(GEN2)-link; \
	fi
ifndef EMBEDDED
	@if [ -n "$(GEN1)" ] && [ -n "$(GEN2)" ]; then printf "\n$(GREEN)  ✓ done$(NC)\n"; fi
endif
	@if [ -n "$(GEN1)" ] && [ -n "$(GEN2)" ]; then \
		printf "\n$(YELLOW)📋 Quick Actions:$(NC)\n"; \
		printf "$(DIM)────────────────────────────────────────────────────────────────────────────────$(NC)\n"; \
		printf "  • list all generations: $(BLUE)make gen-list$(NC)\n\n"; \
	fi

# ═══════════════════════════════════════════════════════════════
# 📊 GEN-DIFF-CURRENT - Compare current generation with the previous one
# ═══════════════════════════════════════════════════════════════
# ──── Auto-detects current generation number ────────────────
gen-diff-current: ## Compare current generation with previous
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)📊 gen-diff-current · current vs previous$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
endif
	@CURRENT=$$(sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | grep current | awk '{print $$1}'); \
	PREVIOUS=$$((CURRENT - 1)); \
	if [ $$PREVIOUS -gt 0 ]; then \
		printf "$(DIM)  gen $$PREVIOUS (previous) → gen $$CURRENT (current)$(NC)\n\n"; \
		if command -v nix-diff >/dev/null 2>&1; then \
			nix-diff /nix/var/nix/profiles/system-$$PREVIOUS-link /nix/var/nix/profiles/system-$$CURRENT-link; \
		else \
			printf "$(YELLOW)  ⚠  nix-diff not found — add it to your packages$(NC)\n"; \
			printf "$(DIM)  nix run nixpkgs#nix-diff -- /nix/var/nix/profiles/system-$$PREVIOUS-link /nix/var/nix/profiles/system-$$CURRENT-link$(NC)\n"; \
		fi; \
	else \
		printf "$(YELLOW)  ⚠  no previous generation found$(NC)\n"; \
	fi
ifndef EMBEDDED
	@printf "\n$(GREEN)  ✓ done$(NC)\n"
endif
	@printf "\n$(YELLOW)📋 Quick Actions:$(NC)\n"
	@printf "$(DIM)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "  • compare any two: $(BLUE)make gen-diff GEN1=n GEN2=m$(NC)\n"
	@printf "  • list generations: $(BLUE)make gen-list$(NC)\n\n"

# ═══════════════════════════════════════════════════════════════
# 💾 GEN-SIZES - Show disk usage for all generations
# ═══════════════════════════════════════════════════════════════
# ──── Reports 'du -sh' size for each system generation link ────
gen-sizes: ## Show size of generations
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)💾 gen-sizes · disk usage per generation$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
endif
	@sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | \
	while read -r gen date time flags; do \
		LINK="/nix/var/nix/profiles/system-$$gen-link"; \
		TARGET=$$(readlink -f "$$LINK" 2>/dev/null); \
		if [ -n "$$TARGET" ]; then \
			SIZE_BYTES=$$(nix path-info -S "$$TARGET" 2>/dev/null | awk '{print $$2}'); \
			HUMAN=$$(echo "$$SIZE_BYTES" | awk '{if($$1>1073741824) printf "%.1fG",$$1/1073741824; else if($$1>1048576) printf "%.1fM",$$1/1048576; else if($$1>1024) printf "%.1fK",$$1/1024; else printf "%dB",$$1}'); \
			MARKER=""; \
			if echo "$$flags" | grep -q "current"; then MARKER=" ◀ current"; fi; \
			printf "  Gen %-4s: %-8s  %s%s\n" "$$gen" "$$HUMAN" "$$date" "$$MARKER"; \
		else \
			printf "  Gen %-4s: (link not found)\n" "$$gen"; \
		fi; \
	done
ifndef EMBEDDED
	@printf "\n$(GREEN)  ✓ done$(NC)\n"
endif
	@printf "\n$(YELLOW)📋 Quick Actions:$(NC)\n"
	@printf "$(DIM)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "  • list generations:  $(BLUE)make gen-list$(NC)\n"
	@printf "  • current gen info:  $(BLUE)make gen-current$(NC)\n\n"

# ═══════════════════════════════════════════════════════════════
# 📌 GEN-CURRENT - Show details of the active generation
# ═══════════════════════════════════════════════════════════════
# ──── Filters nix-env generation list for 'current' marker ─────
gen-current: ## Show current generation info
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)📌 gen-current · active generation$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
endif
	@sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | grep current
ifndef EMBEDDED
	@printf "\n$(GREEN)  ✓ done$(NC)\n"
endif
	@printf "\n$(YELLOW)📋 Quick Actions:$(NC)\n"
	@printf "$(DIM)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "  • list all:           $(BLUE)make gen-list$(NC)\n"
	@printf "  • diff current/prev:  $(BLUE)make gen-diff-current$(NC)\n\n"
