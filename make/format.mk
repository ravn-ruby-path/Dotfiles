# ═══════════════════════════════════════════════════════════════
# 🎨 FORMATTING AND LINTING - Code quality and structure tools
# ═══════════════════════════════════════════════════════════════
# 📚 Documentation: docs/src/content/docs/makefile/09-format.mdx
# 🎯 Purpose: Format, lint, and visualize Nix code and project structure
# ──── Overview: 4 targets for code quality and diff utilities ───────
#
# 🧪 Dry Run (preview without executing):
#    make fmt-check  DRY_RUN=1   · skip running formatter
#    (fmt-lint, fmt-tree, fmt-diff are read-only)

.PHONY: fmt-check fmt-lint fmt-tree fmt-diff

DRY_RUN ?= 0
export DRY_RUN
ifeq ($(DRY_RUN),1)
  EXEC = echo "  ▶ [dry-run]"
else
  EXEC =
endif

# === Formatting and Structure ===

# ═══════════════════════════════════════════════════════════════
# 🎨 FMT-CHECK - Format all Nix files (alejandra or nixpkgs-fmt)
# ═══════════════════════════════════════════════════════════════
# ──── Auto-detects available formatter ─────────────────────────
fmt-check: ## Format all nix files
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)🎨 fmt-check · format Nix files$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
endif
	@if command -v alejandra >/dev/null 2>&1; then \
		printf "$(DIM)  running Alejandra formatter...$(NC)\n"; \
		if [ "$$DRY_RUN" = "1" ]; then echo "  ▶ [dry-run] alejandra ."; else alejandra .; fi; \
	elif command -v nixpkgs-fmt >/dev/null 2>&1; then \
		printf "$(DIM)  running nixpkgs-fmt...$(NC)\n"; \
		if [ "$$DRY_RUN" = "1" ]; then echo "  ▶ [dry-run] nixpkgs-fmt ."; else nixpkgs-fmt .; fi; \
	else \
		printf "$(YELLOW)  ⚠️  no formatter found (alejandra/nixpkgs-fmt)$(NC)\n"; \
	fi
ifndef EMBEDDED
	@printf "\n$(GREEN)  ✓ done$(NC)\n"
endif
	@printf "\n$(YELLOW)📋 Quick Actions:$(NC)\n"
	@printf "$(DIM)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "  • lint for issues: $(BLUE)make fmt-lint$(NC)\n\n"

# ═══════════════════════════════════════════════════════════════
# 🔎 FMT-LINT - Lint Nix files for common issues
# ═══════════════════════════════════════════════════════════════
# ──── Uses statix to detect anti-patterns in Nix code ────────
fmt-lint: ## Check nix files for common issues
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)🔎 fmt-lint · lint Nix files$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
endif
	@if command -v statix >/dev/null 2>&1; then \
		printf "$(DIM)  running Statix linter...$(NC)\n"; \
		statix check .; \
	else \
		printf "$(YELLOW)  ⚠️  statix not found, skipping$(NC)\n"; \
	fi
ifndef EMBEDDED
	@printf "\n$(GREEN)  ✓ done$(NC)\n"
endif
	@printf "\n$(YELLOW)📋 Quick Actions:$(NC)\n"
	@printf "$(DIM)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "  • format files: $(BLUE)make fmt-check$(NC)\n\n"

# ═══════════════════════════════════════════════════════════════
# 📂 FMT-TREE - Show project structure tree
# ═══════════════════════════════════════════════════════════════
# ──── Excludes result*, node_modules, .git ────────────────────
fmt-tree: ## Show project structure tree
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)📂 fmt-tree · project structure$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
endif
	@if command -v tree >/dev/null 2>&1; then \
		tree -L 2 -I "result*|node_modules|.git"; \
	else \
		find . -maxdepth 2 -not -path '*/.*' -not -path './result*' -not -path './docs/node_modules*'; \
	fi
ifndef EMBEDDED
	@printf "\n$(GREEN)  ✓ done$(NC)\n"
endif
	@printf "\n$(YELLOW)📋 Quick Actions:$(NC)\n"
	@printf "$(DIM)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "  • diff vs /etc/nixos: $(BLUE)make fmt-diff$(NC)\n\n"

# ═══════════════════════════════════════════════════════════════
# 📉 FMT-DIFF - Show diff between local and system config
# ═══════════════════════════════════════════════════════════════
# ──── Compares local .nix files against /etc/nixos ───────────
fmt-diff: ## Show diff between local and system config
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)📉 fmt-diff · local vs /etc/nixos$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
endif
	@printf "$(DIM)  comparing local configuration with /etc/nixos...$(NC)\n"
	@if [ -d "/etc/nixos" ]; then \
		diff -r . /etc/nixos --exclude=".git" --exclude="result*" || true; \
	else \
		printf "$(RED)  ❌ /etc/nixos not found$(NC)\n"; \
	fi
ifndef EMBEDDED
	@printf "\n$(GREEN)  ✓ done$(NC)\n"
endif
	@printf "\n$(YELLOW)📋 Quick Actions:$(NC)\n"
	@printf "$(DIM)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "  • format files: $(BLUE)make fmt-check$(NC)\n\n"
