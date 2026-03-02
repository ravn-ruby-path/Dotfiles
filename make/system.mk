# ═══════════════════════════════════════════════════════════════
# 🔄 SYSTEM MANAGEMENT - NixOS rebuild and deployment operations
# ═══════════════════════════════════════════════════════════════
# 📚 Documentation: docs/src/content/docs/makefile/01-system.mdx
# 🎯 Purpose: Core system rebuild, validation, and deployment targets
# 🔍 Scope: Build, switch, test, and debug NixOS configurations
# ──── Overview: 16 targets for complete system lifecycle management ─

.PHONY: sys-apply sys-apply-safe sys-apply-fast sys-test sys-build sys-dry-run sys-boot sys-check sys-debug sys-force sys-doctor sys-fix-git sys-hw-scan sys-deploy sys-copy-hw-config sys-apply-core

# ═══════════════════════════════════════════════════════════════
# 🚀 SYSTEM OPERATIONS - Core rebuild and deployment workflows
# ═══════════════════════════════════════════════════════════════
# ──── Build and Switch: Primary system update operations ────

# ──── Standard Apply: Build and activate new system configuration ─
sys-apply: ## Build and switch to new configuration
	@$(MAKE) --no-print-directory sys-fix-git EMBEDDED=1
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(CYAN)             🔄 System Apply (Build & Switch)           \n$(NC)"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif
	@$(MAKE) --no-print-directory sys-apply-core

# Internal target for validationless apply (logic only)
sys-apply-core:
	@printf "$(BLUE)Executing nixos-rebuild switch...$(NC)\n\n"
	sudo nixos-rebuild switch $(NIX_OPTS) --flake $(FLAKE_DIR)#$(HOSTNAME)
	
	@printf "\n$(BLUE)Next Steps:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "$(YELLOW)To apply shell/theme changes, it is highly recommended to run:$(NC)\n"
	@printf "  $(BLUE)hyde-shell reload$(NC)\n"
	
ifndef EMBEDDED
	@printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(GREEN) ✅ Deployment completed successfully!$(NC)\n"
	@printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif

# ═══════════════════════════════════════════════════════════════
# 🛡️ SAFE DEPLOYMENT - Validate before applying changes
# ═══════════════════════════════════════════════════════════════
# ──── Safe Apply: Validate configuration before deployment ──
sys-apply-safe: sys-check sys-apply ## Validate then switch (safest option)

# ──── Fast Apply: Skip internal nixos-rebuild checks for speed ─
# Fast rebuild skipping internal nixos-rebuild checks for speed
sys-apply-fast: ## Quick rebuild (skip checks)
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(CYAN)             ⚡ Fast Rebuild (Skip Checks)              \n$(NC)"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif
	
	@printf "$(GREEN)1.$(NC) $(BLUE)Fast Switch:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "$(YELLOW)⚠️  Skipping validation checks (--fast enabled)$(NC)\n"
	@printf "$(BLUE)Executing rebuild...$(NC)\n\n"
	sudo nixos-rebuild switch $(NIX_OPTS) --flake $(FLAKE_DIR)#$(HOSTNAME) --fast
	
ifndef EMBEDDED
	@printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(GREEN) ✅ Fast switch complete$(NC)\n"
	@printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif

# ═══════════════════════════════════════════════════════════════
# 🧪 CONFIGURATION TESTING - Test builds without activation
# ═══════════════════════════════════════════════════════════════
sys-test: ## Test Configuration: Build and test without permanent changes
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(CYAN)             🧪 Test Configuration (Dry Switch)         \n$(NC)"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif
	
	@printf "$(GREEN)1.$(NC) $(BLUE)Testing Build:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "$(BLUE)Building system closure...$(NC)\n"
	sudo nixos-rebuild test $(NIX_OPTS) --flake $(FLAKE_DIR)#$(HOSTNAME)
	
ifndef EMBEDDED
	@printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(GREEN) ✅ Test build complete$(NC)\n"
	@printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif

# ═══════════════════════════════════════════════════════════════
# 🔨 BUILD VALIDATION - Compile without activation
# ═══════════════════════════════════════════════════════════════

sys-build: ## Build configuration without switching
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(CYAN)             🔨 Build Configuration (No Activation)     \n$(NC)"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif
	
	@printf "$(GREEN)1.$(NC) $(BLUE)Compilation:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "$(BLUE)Compiling system derivation...$(NC)\n"
	@START=$$(date +%s); \
	sudo nixos-rebuild build $(NIX_OPTS) --flake $(FLAKE_DIR)#$(HOSTNAME); \
	BUILD_EXIT=$$?; \
	END=$$(date +%s); \
	DURATION=$$((END - START)); \
	MINUTES=$$((DURATION / 60)); \
	SECONDS=$$((DURATION % 60)); \
	printf "\n" ; \
	printf "$(GREEN)2.$(NC) $(BLUE)Build Summary:$(NC)\n" ; \
	printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n" ; \
	if [ $$BUILD_EXIT -eq 0 ]; then \
		printf "  $(GREEN)Status:$(NC)     $(GREEN)Success$(NC)\n"; \
		if [ $$MINUTES -gt 0 ]; then \
			printf "  $(GREEN)Duration:$(NC)   $(YELLOW)$${MINUTES}m $${SECONDS}s$(NC) ($${DURATION}s)\n"; \
		else \
			printf "  $(GREEN)Duration:$(NC)   $(YELLOW)$${SECONDS}s$(NC)\n"; \
		fi; \
	if [ -z "$(EMBEDDED)" ]; then \
		printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"; \
		printf "$(GREEN) ✅ Build completed$(NC)\n"; \
		printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"; \
	fi; \
	else \
		printf "  $(RED)Status:$(NC)     $(RED)Failed$(NC)\n"; \
		printf "  $(RED)Duration:$(NC)   $(YELLOW)$${DURATION}s$(NC)\n"; \
	if [ -z "$(EMBEDDED)" ]; then \
		printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"; \
		printf "$(RED) ❌ Build failed$(NC)\n"; \
		printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"; \
	fi; \
	fi; \
	printf "\n"; \
	exit $$BUILD_EXIT

# ═══════════════════════════════════════════════════════════════
# 🔍 DRY RUN ANALYSIS - Preview changes without building
# ═══════════════════════════════════════════════════════════════

sys-dry-run: ## Preview what would be built or changed without actually building

ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(CYAN)             🔍 Dry Run Strategy Preview                \n$(NC)"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif
	
	@printf "$(GREEN)1.$(NC) $(BLUE)Analyzing Changes:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "$(BLUE)Calculating build plan...$(NC)\n\n"
	@sudo nixos-rebuild dry-run $(NIX_OPTS) --flake $(FLAKE_DIR)#$(HOSTNAME)
	
ifndef EMBEDDED
	@printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(GREEN) ✅ Dry run complete$(NC)\n"
	@printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif

# ═══════════════════════════════════════════════════════════════
# 🥾 BOOT CONFIGURATION - Set as default for next boot
# ═══════════════════════════════════════════════════════════════

sys-boot: ## Build and set as default for next boot (no immediate switch)


ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(CYAN)             🥾 Configure Next Boot                     \n$(NC)"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif
	
	@printf "$(GREEN)1.$(NC) $(BLUE)Boot Configuration:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "$(BLUE)Building system and adding to bootloader...$(NC)\n\n"
	sudo nixos-rebuild boot $(NIX_OPTS) --flake $(FLAKE_DIR)#$(HOSTNAME)
	
ifndef EMBEDDED
	@printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(GREEN) ✅ Next boot configured$(NC)\n"
	@printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif

# ═══════════════════════════════════════════════════════════════
# 🔍 VALIDATION AND DEBUGGING - Configuration testing and troubleshooting
# ═══════════════════════════════════════════════════════════════

sys-check: ## Validate configuration before applying
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(CYAN)             🔍 System Integrity Check                  \n$(NC)"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif
	
	@printf "$(GREEN)1.$(NC) $(BLUE)Validations:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "$(BLUE)Checking flake syntax...              $(NC)"
	@if nix flake check $(FLAKE_DIR) >/dev/null 2>&1; then \
		printf "$(GREEN)✓ Passed$(NC)\n"; \
	else \
		printf "$(RED)✗ Failed$(NC)\n"; \
		nix flake check $(FLAKE_DIR); \
		exit 1; \
	fi
	@printf "$(BLUE)2/3 Checking configuration evaluation...$(NC) "
	@if nix eval .#nixosConfigurations.$(HOSTNAME).config.system.build.toplevel >/dev/null 2>&1; then \
		printf "$(GREEN)✓ Passed$(NC)\n"; \
	else \
		printf "$(RED)✗ Failed$(NC)\n"; \
		nix eval .#nixosConfigurations.$(HOSTNAME).config.system.build.toplevel --show-trace; \
		exit 1; \
	fi
	@printf "$(BLUE)3/3 Checking for common issues...$(NC) "
	@if command -v statix >/dev/null 2>&1; then \
		if statix check . >/dev/null 2>&1; then \
			printf "$(GREEN)✓ Passed$(NC)\n"; \
		else \
			printf "$(YELLOW)⚠ Warnings found (run 'make fmt-lint')$(NC)\n"; \
		fi; \
	else \
		printf "$(YELLOW)⊘ Not installed$(NC)\n"; \
	fi
	
ifndef EMBEDDED
	@printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(GREEN) ✅ All checks passed$(NC)\n"
	@printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif

# ═══════════════════════════════════════════════════════════════
# 🐛 DEBUGGING - Verbose rebuild with full tracing
# ═══════════════════════════════════════════════════════════════

# Rebuild with maximum verbosity and debug tracing enabled
sys-debug: ## Rebuild with verbose output and trace
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(CYAN)             🐛 Debug Rebuild (Verbose)                 \n$(NC)"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif
	@printf "$(GREEN)1.$(NC) $(BLUE)Starting Debug Build:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	sudo nixos-rebuild switch $(NIX_OPTS) --flake $(FLAKE_DIR)#$(HOSTNAME) --show-trace --verbose

# ═══════════════════════════════════════════════════════════════
# 🚨 EMERGENCY RECOVERY - Force rebuild with maximum debugging
# ═══════════════════════════════════════════════════════════════

sys-force: ## Emergency rebuild with maximum verbosity
ifndef EMBEDDED
	@printf "\n"
	@printf "$(RED)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(RED)             🚨 Emergency System Rebuild                \n$(NC)"
	@printf "$(RED)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif
	
	@printf "$(GREEN)1.$(NC) $(BLUE)Critical Operation:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "$(RED)⚠️  FORCED REBUILD ACTIVATED$(NC)\n"
	@printf "$(YELLOW)• Disabling evaluation cache$(NC)\n"
	@printf "$(YELLOW)• Enabling maximum verbosity$(NC)\n"
	@printf "$(YELLOW)• Showing full stack trace$(NC)\n\n"
	
	@printf "$(GREEN)2.$(NC) $(BLUE)Executing:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	sudo nixos-rebuild switch \
		$(NIX_OPTS) \
		--option eval-cache false \
		--flake $(FLAKE_DIR)#$(HOSTNAME) \
		--show-trace --verbose
		
ifndef EMBEDDED
	@printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(GREEN) ✅ Forced rebuild complete$(NC)\n"
	@printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif

# ═══════════════════════════════════════════════════════════════
# 🔧 MAINTENANCE AND UTILITIES - System upkeep and helper tools
# ═══════════════════════════════════════════════════════════════
# ──── Complete Workflow: End-to-end deployment automation ────
sys-deploy: ## Total sync (doctor + add + commit + push + apply)
	@printf "\n"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(CYAN)             🚀 Total System Deployment                 \n$(NC)"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
	
	@printf "$(GREEN)1.$(NC) $(BLUE)System Doctor (Permissions):$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@$(MAKE) --no-print-directory sys-doctor EMBEDDED=1

	@printf "\n$(GREEN)2.$(NC) $(BLUE)Git Permissions Fix:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@$(MAKE) --no-print-directory sys-fix-git EMBEDDED=1

	@printf "\n$(GREEN)3.$(NC) $(BLUE)Git Stage Changes:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@$(MAKE) --no-print-directory git-add EMBEDDED=1

	@printf "\n$(GREEN)4.$(NC) $(BLUE)Git Quick Commit:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@$(MAKE) --no-print-directory git-commit EMBEDDED=1

	@printf "\n$(GREEN)5.$(NC) $(BLUE)Git Push to Remote:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@$(MAKE) --no-print-directory git-push EMBEDDED=1

	@printf "\n$(GREEN)6.$(NC) $(BLUE)System Apply (Build & Switch):$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@$(MAKE) --no-print-directory sys-apply-core EMBEDDED=1
	
	@printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(GREEN) ✅ Full deployment successful$(NC)\n"
	@printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"

# === Maintenance and Utilities ===

# ──── Hardware Config: Copy system hardware configuration to repository ─
sys-copy-hw-config: ## Copy hardware config to Dotfiles    
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(CYAN)             📋 Hardware Config Backup                  \n$(NC)"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif
	
	@printf "$(GREEN)1.$(NC) $(BLUE)Syncing Implementation:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "$(BLUE)Copying from /etc/nixos to $(FLAKE_DIR)...$(NC)\n"
	@sudo cp /etc/nixos/hardware-configuration.nix $(FLAKE_DIR)/hardware-configuration.nix
	@sudo chown $$USER:users $(FLAKE_DIR)/hardware-configuration.nix
	@sudo cp /etc/nixos/configuration.nix $(FLAKE_DIR)/configuration.nix
	@sudo chown $$USER:users $(FLAKE_DIR)/configuration.nix
	@printf "$(GREEN)✅ Hardware config copied to $(FLAKE_DIR)/hardware-configuration.nix\n$(NC)"
	@printf "$(GREEN)✅ User config copied to $(FLAKE_DIR)/configuration.nix\n$(NC)"
	@printf "$(BLUE)📋 File permissions set to user: $$USER\n$(NC)"
	@printf "$(CYAN)════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"


# ──── Hardware Scan: Generate new hardware configuration ─
sys-hw-scan: ## Re-scan hardware configuration
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(CYAN)             🔧 Hardware Scan                           \n$(NC)"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif
	
	@printf "$(GREEN)1.$(NC) $(BLUE)Detecting Hardware:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "$(BLUE)Scanning host $(HOSTNAME)...$(NC)\n"
	@sudo nixos-generate-config --show-hardware-config > hosts/$(HOSTNAME)/hardware-configuration-new.nix
	
	@printf "\n$(GREEN)2.$(NC) $(BLUE)Output:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "$(GREEN)✓ New config saved to: host/$(HOSTNAME)/hardware-configuration-new.nix$(NC)\n\n"
	@printf "$(YELLOW)Action Required:$(NC)\n"
	@printf "• Diff:  $(BLUE)diff hosts/$(HOSTNAME)/hardware-configuration{.nix,-new.nix}$(NC)\n"
	@printf "• Apply: $(BLUE)mv hosts/$(HOSTNAME)/hardware-configuration-new.nix hosts/$(HOSTNAME)/hardware-configuration.nix$(NC)\n"
	
ifndef EMBEDDED
	@printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(GREEN) ✅ Scan complete$(NC)\n"
	@printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif

# Fix common permission issues in user directories
# Internal target: used by sys-deploy, but can be called directly if needed
sys-doctor: ## Fix common permission issues (doctor)
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(CYAN)             👨‍⚕️ System Doctor (Permissions)             \n$(NC)"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
	
	@printf "$(BLUE)1. Health Check:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
endif
	@printf "$(BLUE)Checking ~/.config attributes...$(NC) "
	@if [ -d ~/.config ]; then \
		if find ~/.config -maxdepth 1 -not -user $$USER 2>/dev/null | grep -q .; then \
			printf "$(YELLOW)(fixing ownership...)$(NC) "; \
			if sudo chown -R $$USER:users ~/.config 2>/dev/null; then \
				printf "$(GREEN)✓ Fixed$(NC)\n"; \
			else \
				printf "$(RED)✗ Failed$(NC)\n"; \
			fi; \
		else \
			printf "$(GREEN)✓ OK$(NC)\n"; \
		fi; \
	else \
		printf "$(YELLOW)⚠️  (directory not found)$(NC)\n"; \
	fi
	
	@printf "$(BLUE)Checking ~/.local attributes... $(NC) "
	@if [ -d ~/.local ]; then \
		if find ~/.local -maxdepth 1 -not -user $$USER 2>/dev/null | grep -q .; then \
			printf "$(YELLOW)(fixing ownership...)$(NC) "; \
			if sudo chown -R $$USER:users ~/.local 2>/dev/null; then \
				printf "$(GREEN)✓ Fixed$(NC)\n"; \
			else \
				printf "$(RED)✗ Failed$(NC)\n"; \
			fi; \
		else \
			printf "$(GREEN)✓ OK$(NC)\n"; \
		fi; \
	else \
		printf "$(YELLOW)⚠️  Not found$(NC)\n"; \
	fi
	


# Fix git repository ownership issues in the flake directory
sys-fix-git: ## Fix git repo ownership issues in flake dir
	@printf "$(CYAN)                              🔧 Fix Git Permissions                             $(NC)"
	@printf "\n$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@if [ -d "$(FLAKE_DIR)/.git/objects" ]; then \
		if find "$(FLAKE_DIR)/.git/objects" -maxdepth 2 -type d -not -user $$USER 2>/dev/null | grep -q .; then \
			printf "  $(YELLOW)Fixing ownership in $(FLAKE_DIR)/.git...$(NC) "; \
			if sudo chown -R $$USER:users "$(FLAKE_DIR)/.git" 2>/dev/null; then \
				printf "\n"; \
				printf "$(GREEN)✓$(NC)\n"; \
			else \
				printf "\n"; \
				printf "$(RED)✗$(NC)\n"; \
			fi; \
		else \
			printf "\n"; \
			printf "  $(GREEN)✓ Git permissions OK$(NC)\n"; \
		fi; \
	else \
		printf "\n"; \
		printf "  $(YELLOW)⚠️  No git repository found at $(FLAKE_DIR)$(NC)\n"; \
	fi
