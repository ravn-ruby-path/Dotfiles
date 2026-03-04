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
# 📋 FMT-REPORT - Generate AI-ready quality report in logs/
# ═══════════════════════════════════════════════════════════════
# ──── Report: alejandra --check + statix → logs/nix-report-*.log ─
fmt-report: ## Generate AI-ready lint/format report in logs/
	@printf "\n"
	@printf "$(CYAN)📋 fmt-report · generating quality report$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@mkdir -p logs
	@LOG_FILE="logs/nix-report-$$(date '+%Y%m%d-%H%M%S').log"; \
	ALEJ_OUT=$$(alejandra --check . 2>&1 || true); \
	STATIX_OUT=$$(statix check . 2>&1 || true); \
	{ \
	  echo "═══════════════════════════════════════════════════════════════"; \
	  echo "  NIX QUALITY REPORT — $$(date '+%Y-%m-%d %H:%M:%S')"; \
	  echo "  Repo: $$(git remote get-url origin 2>/dev/null || echo local)"; \
	  echo "  Branch: $$(git branch --show-current 2>/dev/null || echo unknown)"; \
	  echo "═══════════════════════════════════════════════════════════════"; \
	  echo ""; \
	  echo "──── Alejandra (format check) ──────────────────────────────────"; \
	  echo "$$ALEJ_OUT"; \
	  echo ""; \
	  echo "──── Statix (lint warnings) ────────────────────────────────────"; \
	  echo "$$STATIX_OUT"; \
	  echo ""; \
	  echo "═══════════════════════════════════════════════════════════════"; \
	  echo "  AI PROMPT"; \
	  echo "═══════════════════════════════════════════════════════════════"; \
	  echo ""; \
	  echo "I have a NixOS flake-based dotfiles repo. The quality report"; \
	  echo "above shows formatting and lint issues. Please:"; \
	  echo ""; \
	  echo "1. Explain what each warning means in the context of Nix"; \
	  echo "2. Show the exact fix for each issue with a code snippet"; \
	  echo "3. Confirm if any are intentional false positives (e.g. INI"; \
	  echo "   attrsets, split systemd keys) to add to statix.toml instead"; \
	} > "$$LOG_FILE"; \
	if [ -z "$$ALEJ_OUT" ] && [ -z "$$STATIX_OUT" ]; then \
	  printf "$(GREEN)  ✓ no issues found$(NC)\n"; \
	else \
	  printf "$(YELLOW)  ⚠  issues found — report saved:$(NC)\n"; \
	  printf "  $(DIM)$$LOG_FILE$(NC)\n"; \
	fi
	@printf "\n$(GREEN)  ✓ done$(NC)\n"
	@printf "\n$(YELLOW)📋 Quick Actions:$(NC)\n"
	@printf "$(DIM)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "  • auto-fix formatting: $(BLUE)make fmt-check$(NC)\n"
	@printf "  • view lint warnings: $(BLUE)make fmt-lint$(NC)\n\n"
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
