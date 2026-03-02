# ═══════════════════════════════════════════════════════════════
# 📚 HELP AND DOCUMENTATION - Commands reference and docs site
# ═══════════════════════════════════════════════════════════════
# 📚 Documentation: docs/src/content/docs/makefile/01-docs.mdx
# 🎯 Purpose: Display help, usage examples and manage the Astro docs site
# ──── Overview: 7 targets for help display and docs site management ─
#
# 🧪 Dry Run (preview without executing):
#    make doc-dev     DRY_RUN=1   · skip starting dev server
#    make doc-build   DRY_RUN=1   · skip npm run build
#    make doc-install DRY_RUN=1   · skip npm install
#    make doc-clean   DRY_RUN=1   · skip rm -rf
#    (help, help-examples, doc-local are read-only)

.PHONY: help help-examples doc-local doc-dev doc-build doc-install doc-clean

# ──── Dry Run: make <target> DRY_RUN=1 to preview without executing ─
DRY_RUN ?= 0
export DRY_RUN
ifeq ($(DRY_RUN),1)
  EXEC = echo "  ▶ [dry-run]"
else
  EXEC =
endif

# === Help and Documentation ===

# ═══════════════════════════════════════════════════════════════
# 📖 HELP - Show all available commands organized by category
# ═══════════════════════════════════════════════════════════════
# ──── Uses AWK to parse ## comments into a formatted menu ─────
help: ## Show this help message
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)📖 help · all available commands$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
endif
	@grep -hE '^[a-zA-Z0-9_-]+:.*##' $(MAKEFILE_LIST) | \
	sort | \
	awk -v PURPLE="$(PURPLE)" -v GREEN="$(GREEN)" -v DIM="$(DIM)" -v NC="$(NC)" \
	'BEGIN {FS=":.*##"} /^[a-zA-Z0-9_-]+:.*##/ {desc[$$1]=$$2} \
	function print_cat(title, list,    n,i,cmd) { \
		printf "\n%s%s%s\n", PURPLE, title, NC; \
		n = split(list, arr, " "); \
		for (i=1; i<=n; i++) { \
			cmd = arr[i]; \
			if (cmd in desc) { \
				printf "  %s%-25s%s %s%s%s\n", GREEN, cmd, NC, DIM, desc[cmd], NC; \
			} \
		} \
	} \
	END { \
		print_cat("Documentation & Help", "help help-examples help-aliases doc-local doc-dev doc-build doc-install doc-clean"); \
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
	@printf "\n$(GREEN)  ✓ done$(NC)\n"
endif
	@printf "\n$(YELLOW)📋 Quick Actions:$(NC)\n"
	@printf "$(DIM)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "  • usage examples: $(BLUE)make help-examples$(NC)\n"
	@printf "  • legacy aliases: $(BLUE)make help-aliases$(NC)\n\n"

# ═══════════════════════════════════════════════════════════════
# 💡 HELP-EXAMPLES - Show usage examples for common workflows
# ═══════════════════════════════════════════════════════════════
# ──── Displays categorized practical command examples ──────────
help-examples: ## Show usage examples for common workflows
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)💡 help-examples · common workflows$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
endif
	@printf "\n$(PURPLE)System Maintenance:$(NC)\n"
	@printf "  $(GREEN)make sys-apply$(NC)              $(DIM)# Apply system configuration (rebuild switch)$(NC)\n"
	@printf "  $(GREEN)make sys-apply-fast$(NC)         $(DIM)# Faster apply (skips some checks)$(NC)\n"
	@printf "  $(GREEN)make sys-test$(NC)               $(DIM)# Build and test without applying$(NC)\n"
	@printf "  $(GREEN)make sys-status$(NC)             $(DIM)# Show system health and status$(NC)\n"
	@printf "\n$(PURPLE)Update Management:$(NC)\n"
	@printf "  $(GREEN)make upd-all$(NC)                $(DIM)# Update all flake inputs and apply changes$(NC)\n"
	@printf "  $(GREEN)make upd-input PKG=nixpkgs$(NC)  $(DIM)# Update specific input$(NC)\n"
	@printf "  $(GREEN)make upd-check$(NC)              $(DIM)# Check for updates without applying$(NC)\n"
	@printf "\n$(PURPLE)Garbage Collection:$(NC)\n"
	@printf "  $(GREEN)make sys-gc$(NC)                 $(DIM)# Standard cleanup (older than 30 days)$(NC)\n"
	@printf "  $(GREEN)make sys-gc DAYS=7$(NC)          $(DIM)# Aggressive cleanup (older than 7 days)$(NC)\n"
	@printf "  $(GREEN)make sys-optimize$(NC)           $(DIM)# Optimize nix store (deduplication)$(NC)\n"
	@printf "\n$(PURPLE)Development Tools:$(NC)\n"
	@printf "  $(GREEN)make dev-shell$(NC)              $(DIM)# Enter development shell$(NC)\n"
	@printf "  $(GREEN)make dev-search PKG=git$(NC)     $(DIM)# Search for 'git' in nixpkgs$(NC)\n"
	@printf "  $(GREEN)make dev-vm HOST=laptop$(NC)     $(DIM)# Build VM for 'laptop' host$(NC)\n"
	@printf "\n$(PURPLE)Git Operations:$(NC)\n"
	@printf "  $(GREEN)make git-status$(NC)             $(DIM)# Show repository status$(NC)\n"
	@printf "  $(GREEN)make git-commit$(NC)             $(DIM)# Commit changes with timestamp$(NC)\n"
	@printf "  $(GREEN)make sys-deploy$(NC)             $(DIM)# Full deployment cycle (format, test, commit, push)$(NC)\n"
ifndef EMBEDDED
	@printf "\n$(GREEN)  ✓ done$(NC)\n"
endif
	@printf "\n$(YELLOW)📋 Quick Actions:$(NC)\n"
	@printf "$(DIM)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "  • view all commands: $(BLUE)make help$(NC)\n\n"

# ═══════════════════════════════════════════════════════════════
# 📂 DOC-LOCAL - Show local documentation files
# ═══════════════════════════════════════════════════════════════
# ──── Scans for README, tutorials and docs/ directory ────────
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

# ═══════════════════════════════════════════════════════════════
# 🛠️  DOC-DEV - Start Astro documentation development server
# ═══════════════════════════════════════════════════════════════
# ──── Auto-installs dependencies if needed ───────────────────
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

# ═══════════════════════════════════════════════════════════════
# 🏗️  DOC-BUILD - Build the static documentation site
# ═══════════════════════════════════════════════════════════════
# ──── Runs 'npm run build' in docs/ directory ─────────────────
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

# ═══════════════════════════════════════════════════════════════
# 📥 DOC-INSTALL - Install documentation Node.js dependencies
# ═══════════════════════════════════════════════════════════════
# ──── Run before doc-dev or doc-build ────────────────────────
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

# ═══════════════════════════════════════════════════════════════
# 🧹 DOC-CLEAN - Remove documentation build artifacts
# ═══════════════════════════════════════════════════════════════
# ──── Deletes docs/dist and docs/node_modules ─────────────────
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
