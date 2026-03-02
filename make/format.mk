# ═══════════════════════════════════════════════════════════════
# 🎨 FORMATTING AND LINTING - Code quality and structure tools
# ═══════════════════════════════════════════════════════════════
# 📚 Documentation: docs/src/content/docs/makefile/09-format.mdx
# 🎯 Purpose: Format, lint, and visualize Nix code and project structure
# ──── Overview: 4 targets for code quality and diff utilities ───────

.PHONY: fmt-check fmt-lint fmt-tree fmt-diff

# === Formatting and Structure ===

# ═══════════════════════════════════════════════════════════════
# 🎨 FMT-CHECK - Format all Nix files (alejandra or nixpkgs-fmt)
# ═══════════════════════════════════════════════════════════════
# ──── Auto-detects available formatter ─────────────────────────
# Format all Nix files using nixpkgs-fmt or alejandra
fmt-check: ## Format all nix files
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(CYAN)             🎨 Formatting Nix Code                     \n$(NC)"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif
	
	@printf "$(GREEN)1.$(NC) $(BLUE)Formatting Files:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@if command -v alejandra >/dev/null 2>&1; then \
		printf "$(BLUE)Running Alejandra formatter...$(NC)\n"; \
		alejandra .; \
	elif command -v nixpkgs-fmt >/dev/null 2>&1; then \
		printf "$(BLUE)Running nixpkgs-fmt...$(NC)\n"; \
		nixpkgs-fmt .; \
	else \
		printf "$(YELLOW)⚠️  No formatter found (alejandra/nixpkgs-fmt). Skipping.$(NC)\n"; \
	fi
	
ifndef EMBEDDED
	@printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(GREEN) ✅ Formatting complete$(NC)\n"
	@printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif

# ═══════════════════════════════════════════════════════════════
# 🔎 FMT-LINT - Lint Nix files for common issues
# ═══════════════════════════════════════════════════════════════
# ──── Uses statix to detect anti-patterns in Nix code ────────
# Lint Nix files for common issues using statix
fmt-lint: ## Check nix files for common issues
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(CYAN)             🔎 Linting Nix Code                        \n$(NC)"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif
	
	@printf "$(GREEN)1.$(NC) $(BLUE)Running Linter:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@if command -v statix >/dev/null 2>&1; then \
		printf "$(BLUE)Running Statix linter...$(NC)\n"; \
		statix check .; \
	else \
		printf "$(YELLOW)⚠️  Statix not found. Skipping linting.$(NC)\n"; \
	fi
	
ifndef EMBEDDED
	@printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(GREEN) ✅ Linting process finished$(NC)\n"
	@printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif

# ═══════════════════════════════════════════════════════════════
# 📂 FMT-TREE - Show project structure tree
# ═══════════════════════════════════════════════════════════════
# ──── Excludes result*, node_modules, .git ────────────────────
# Show project structure tree
fmt-tree: ## Show project structure tree
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(CYAN)             📂 Project Structure                       \n$(NC)"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif
	
	@printf "$(GREEN)1.$(NC) $(BLUE)Directory Tree:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@if command -v tree >/dev/null 2>&1; then \
		tree -L 2 -I "result*|node_modules|.git"; \
	else \
		find . -maxdepth 2 -not -path '*/.*' -not -path './result*' -not -path './docs/node_modules*'; \
	fi
	
ifndef EMBEDDED
	@printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(GREEN) ✅ Tree view complete$(NC)\n"
	@printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif

# ═══════════════════════════════════════════════════════════════
# 📉 FMT-DIFF - Show diff between local and system config
# ═══════════════════════════════════════════════════════════════
# ──── Compares local .nix files against /etc/nixos ───────────
# Show diff between local and system config
fmt-diff: ## Show diff between local and system config
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(CYAN)             📉 Configuration Difference                \n$(NC)"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif
	
	@printf "$(GREEN)1.$(NC) $(BLUE)Calculating Diff:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "$(BLUE)Comparing local configuration with /etc/nixos...$(NC)\n"
	@if [ -d "/etc/nixos" ]; then \
		diff -r . /etc/nixos --exclude=".git" --exclude="result*" || true; \
	else \
		printf "$(RED)❌ /etc/nixos not found$(NC)\n"; \
	fi
	
ifndef EMBEDDED
	@printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(GREEN) ✅ Diff complete$(NC)\n"
	@printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif
