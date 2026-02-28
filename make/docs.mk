# ============================================================================
# Help and Documentation
# ============================================================================
# Description: Targets for displaying help, examples, and documentation
# Documentation: docs/src/content/docs/makefile/01-docs.mdx
# Targets: 7 targets
# ============================================================================

.PHONY: help help-examples docs-local doc-dev doc-build doc-install doc-clean

# === Help and Documentation ===

# Main help target - shows all available commands organized by category
# Uses AWK to parse inline comments (##) and display them in a formatted menu
help: ## Show this help message
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(CYAN)             📚 System Commands & Documentation         \n$(NC)"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif
	
	@printf "$(GREEN)1.$(NC) $(BLUE)Command Reference:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@grep -hE '^[a-zA-Z0-9_-]+:.*##' $(MAKEFILE_LIST) | \
	sort | \
	awk 'BEGIN {FS=":.*##"} /^[a-zA-Z0-9_-]+:.*##/ {desc[$$1]=$$2} \
	function print_cat(title, list,    n,i,cmd) { \
		printf "\n%s%s%s\n", BLUE, title, NC; \
		n = split(list, arr, " "); \
		for (i=1; i<=n; i++) { \
			cmd = arr[i]; \
			if (cmd in desc) { \
				printf "  %s%-25s%s %s\n", GREEN, cmd, NC, desc[cmd]; \
			} \
		} \
	} \
	END { \
		print_cat("Documentation & Help", "help help-examples help-aliases docs-local doc-dev doc-build doc-install doc-clean"); \
		print_cat("System Maintenance", "sys-apply sys-apply-safe sys-apply-fast sys-test sys-build sys-dry-run sys-boot sys-check sys-debug sys-force sys-doctor sys-fix-git sys-hw-scan sys-copy-hw-config sys-deploy"); \
		print_cat("Cleanup & Optimization", "sys-gc sys-purge sys-optimize sys-clean-result sys-fix-store"); \
		print_cat("Updates & Flakes", "upd-all upd-nixpkgs upd-hydenix upd-input upd-ai upd-diff upd-upgrade upd-show upd-check"); \
		print_cat("Generations & Rollback", "gen-list gen-rollback gen-rollback-commit gen-diff gen-diff-current gen-sizes gen-current"); \
		print_cat("Git Operations", "git-add git-commit git-add-commit git-push git-status git-diff git-log"); \
		print_cat("Diagnostics & Logs", "sys-status log-net log-net-enhanced log-watch log-boot log-err log-svc"); \
		print_cat("Development Tools", "dev-hosts dev-search dev-search-inst dev-repl dev-shell dev-vm dev-size"); \
		print_cat("Formatting & Linting", "fmt-check fmt-lint fmt-tree fmt-diff"); \
	}'
	
ifndef EMBEDDED
	@printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(GREEN) ✅ End of help$(NC)\n"
	@printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif
	@printf "$(YELLOW)📋 Quick Actions:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "• Usage examples:    $(BLUE)make help-examples$(NC)\n"
	@printf "• Legacy aliases:    $(BLUE)make help-aliases$(NC)\n"
	@printf "\n"

# Show detailed usage examples for commands that require parameters
# Organized by category with practical examples
help-examples: ## Show usage examples for common workflows
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(CYAN)             💡 Common Workflows & Examples             \n$(NC)"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif

	@printf "$(GREEN)1.$(NC) $(BLUE)System Maintenance:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "  $(GREEN)make sys-apply$(NC)           # Apply system configuration (rebuild switch)\n"
	@printf "  $(GREEN)make sys-apply-fast$(NC)      # Faster apply (skips some checks)\n"
	@printf "  $(GREEN)make sys-test$(NC)            # Build and test (dry-run) without applying\n"
	@printf "  $(GREEN)make sys-status$(NC)          # Show system health and status\n"

	@printf "\n$(GREEN)2.$(NC) $(BLUE)Update Management:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "  $(GREEN)make upd-all$(NC)             # Update all flake inputs and apply changes\n"
	@printf "  $(GREEN)make upd-input PKG=nixpkgs$(NC) # Update specific input (e.g. nixpkgs)\n"
	@printf "  $(GREEN)make upd-check$(NC)           # Check for updates without applying\n"

	@printf "\n$(GREEN)3.$(NC) $(BLUE)Garbage Collection:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "  $(GREEN)make sys-gc$(NC)              # Standard cleanup (older than 30 days)\n"
	@printf "  $(GREEN)make sys-gc DAYS=7$(NC)       # Aggressive cleanup (older than 7 days)\n"
	@printf "  $(GREEN)make sys-optimize$(NC)        # Optimize nix store (deduplication)\n"

	@printf "\n$(GREEN)4.$(NC) $(BLUE)Development Tools:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "  $(GREEN)make dev-shell$(NC)           # Enter development shell\n"
	@printf "  $(GREEN)make dev-search PKG=git$(NC)  # Search for 'git' in nixpkgs\n"
	@printf "  $(GREEN)make dev-vm HOST=laptop$(NC)  # Build VM for 'laptop' host\n"
	
	@printf "\n$(GREEN)5.$(NC) $(BLUE)Git Operations:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "  $(GREEN)make git-status$(NC)          # Show repository status\n"
	@printf "  $(GREEN)make git-commit$(NC)          # Commit changes with timestamp\n"
	@printf "  $(GREEN)make sys-deploy$(NC)          # Full deployment cycle (format, test, commit, push)\n"

ifndef EMBEDDED
	@printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(GREEN) ✅ End of examples$(NC)\n"
	@printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif
	@printf "$(YELLOW)📋 Quick Actions:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "• View commands:     $(BLUE)make help$(NC)\n"
	@printf "\n"

# List all available documentation files in the project
# Scans for README, tutorials, and docs/ directory
doc-local: ## Show local documentation files
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(CYAN)             📚 Local Documentation                     \n$(NC)"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif
	
	@printf "$(GREEN)1.$(NC) $(BLUE)Documentation Files:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@if [ -d "docs/src/content/docs" ]; then \
		find docs/src/content/docs -name "*.md*" | sed 's|^docs/src/content/docs/|  📄 |'; \
	elif [ -d "docs" ]; then \
		find docs -name "*.md" | sed 's|^docs/|  📄 |'; \
	else \
		printf "$(RED)❌ 'docs' directory not found$(NC)\n"; \
	fi
	@if [ -f "README.md" ]; then \
		printf "  📄 README.md\n"; \
	fi
	
ifndef EMBEDDED
	@printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(GREEN) ✅ List complete$(NC)\n"
	@printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif

# Start Astro documentation development server
# Automatically installs dependencies if needed
doc-dev: ## Run documentation dev server
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(CYAN)             🛠️  Starting Documentation Server          \n$(NC)"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif
	@printf "$(GREEN)1.$(NC) $(BLUE)Launching Server:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "$(BLUE)Starting Astro dev server...$(NC)\n"
	@cd docs && npm run dev

# Build static documentation site
doc-build: ## Build documentation site
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(CYAN)             🏗️  Building Documentation                 \n$(NC)"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif
	@printf "$(GREEN)1.$(NC) $(BLUE)Building Site:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "$(BLUE)Generating static site (Astro build)...$(NC)\n"
	@cd docs && npm run build
	@printf "$(GREEN)✓ Build complete$(NC)\n"
	@printf "\n"

# Install documentation dependencies
# Run this before using docs-dev or docs-build
doc-install: ## Install documentation dependencies
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(CYAN)             📥 Installing Documentation Tools          \n$(NC)"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif
	@printf "$(GREEN)1.$(NC) $(BLUE)Installing Node.js dependencies...$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@cd docs && npm install
ifndef EMBEDDED
	@printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(GREEN) ✅ Installation complete$(NC)\n"
	@printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif

# Clean documentation build artifacts
doc-clean: ## Clean documentation artifacts
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(CYAN)             🧹 Cleaning Documentation Artifacts        \n$(NC)"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif
	@printf "$(GREEN)1.$(NC) $(BLUE)Cleaning:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@rm -rf docs/dist docs/node_modules
ifndef EMBEDDED
	@printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(GREEN) ✅ Clean complete$(NC)\n"
	@printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif
