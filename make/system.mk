# ═══════════════════════════════════════════════════════════════
# 🔄 SYSTEM MANAGEMENT - NixOS rebuild and deployment operations
# ═══════════════════════════════════════════════════════════════
# 📚 Documentation: docs/src/content/docs/makefile/01-system.mdx
# 🎯 Purpose: Core system rebuild, validation, and deployment targets
# 🔍 Scope: Build, switch, test, and debug NixOS configurations
# ──── Overview: 16 targets for complete system lifecycle management ─
#
# 🧪 Dry Run (preview without executing):
#    make sys-apply       DRY_RUN=1   · skip nixos-rebuild switch
#    make sys-apply-fast  DRY_RUN=1   · skip nixos-rebuild switch --fast
#    make sys-test        DRY_RUN=1   · skip nixos-rebuild test
#    make sys-build       DRY_RUN=1   · skip nixos-rebuild build
#    make sys-boot        DRY_RUN=1   · skip nixos-rebuild boot
#    make sys-deploy      DRY_RUN=1   · skip all write operations
#    (sys-check, sys-dry-run, sys-debug are read-only — no DRY_RUN needed)
#    make sys-check       DRY_RUN=1   · skip nix eval checks (lightweight)

DRY_RUN ?= 0
export DRY_RUN
ifeq ($(DRY_RUN),1)
  EXEC = echo "  ▶ [dry-run]"
else
  EXEC =
endif

.PHONY: sys-apply sys-apply-safe sys-apply-fast sys-test sys-build sys-dry-run sys-boot sys-check sys-debug sys-force sys-doctor sys-fix-git sys-hw-scan sys-deploy sys-copy-hw-config sys-apply-core

# ═══════════════════════════════════════════════════════════════
# 🚀 SYS-DEPLOY - End-to-end deployment workflow
# ═══════════════════════════════════════════════════════════════
# ──── Deploy: doctor → fix-git → add → commit → push → apply ─
sys-deploy: ## Total sync (doctor + add + commit + push + apply)
	@printf "\n"
	@printf "$(CYAN)🚀 sys-deploy · doctor → git → apply$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "\n$(DIM)  ▶ fixing permissions...$(NC)\n"
	@$(MAKE) --no-print-directory sys-doctor EMBEDDED=1
	@printf "\n$(DIM)  ▶ fixing git ownership...$(NC)\n"
	@$(MAKE) --no-print-directory sys-fix-git EMBEDDED=1
	@printf "\n$(DIM)  ▶ checking format...$(NC)\n"
	@if command -v alejandra >/dev/null 2>&1; then \
		if ! alejandra --check . >/dev/null 2>&1; then \
			printf "$(RED)  ✗ unformatted files found — run: make fmt-check$(NC)\n"; \
			exit 1; \
		fi; \
		printf "$(DIM)    format ok$(NC)\n"; \
	fi
	@printf "\n$(DIM)  ▶ staging changes...$(NC)\n"
	@$(MAKE) --no-print-directory git-add EMBEDDED=1
	@printf "\n$(DIM)  ▶ committing...$(NC)\n"
	@$(MAKE) --no-print-directory git-commit EMBEDDED=1
	@printf "\n$(DIM)  ▶ pushing to remote...$(NC)\n"
	@$(MAKE) --no-print-directory git-push EMBEDDED=1
	@printf "\n$(DIM)  ▶ rebuilding system...$(NC)\n"
	@$(MAKE) --no-print-directory sys-apply-core EMBEDDED=1
	@printf "\n$(GREEN)  ✓ done$(NC)\n"
	@printf "\n$(YELLOW)📋 Quick Actions:$(NC)\n"
	@printf "$(DIM)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "  • verify no errors after deploy: $(BLUE)make log-err$(NC)\n"
	@printf "  • check what was committed: $(BLUE)make git-log$(NC)\n"
	@printf "  • list new generation: $(BLUE)make gen-list$(NC)\n"
	@printf "  $(DIM)hint: run hyde-shell reload to apply shell/theme changes$(NC)\n\n"

# ═══════════════════════════════════════════════════════════════
# 🔄 SYS-APPLY - Build and activate new system configuration
# ═══════════════════════════════════════════════════════════════
# ──── Standard Apply: Fixes git ownership then switches ──────
sys-apply: ## Build and switch to new configuration
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)🔄 sys-apply · build and switch$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
endif
	@$(MAKE) --no-print-directory sys-fix-git EMBEDDED=1
	@$(MAKE) --no-print-directory sys-apply-core

# ═══════════════════════════════════════════════════════════════
# ⚙️  SYS-APPLY-CORE - Internal nixos-rebuild switch target
# ═══════════════════════════════════════════════════════════════
# ──── Apply Core: Internal target — callers own the display ──
sys-apply-core:
	@$(EXEC) sudo nixos-rebuild switch $(NIX_OPTS) --flake $(FLAKE_DIR)#$(HOSTNAME)
ifndef EMBEDDED
	@printf "\n$(GREEN)  ✓ done$(NC)\n"
	@printf "\n$(YELLOW)📋 Quick Actions:$(NC)\n"
	@printf "$(DIM)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "  • verify no errors: $(BLUE)make log-err$(NC)\n"
	@printf "  • check new generation: $(BLUE)make gen-list$(NC)\n"
	@printf "  • rollback if needed: $(BLUE)make gen-rollback$(NC)\n"
	@printf "  $(DIM)hint: run hyde-shell reload to apply shell/theme changes$(NC)\n\n"
endif

# ═══════════════════════════════════════════════════════════════
# 🛡️  SYS-APPLY-SAFE - Validate configuration before switching
# ═══════════════════════════════════════════════════════════════
# ──── Safe Apply: Runs sys-check then sys-apply (safest) ─────
sys-apply-safe: sys-check sys-apply ## Validate then switch (safest option)

# ═══════════════════════════════════════════════════════════════
# ⚡ SYS-APPLY-FAST - Quick rebuild skipping internal checks
# ═══════════════════════════════════════════════════════════════
# ──── Fast Apply: nixos-rebuild switch --fast (skip checks) ──
sys-apply-fast: ## Quick rebuild (skip checks)
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)⚡ sys-apply-fast · skip internal checks$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
endif
	@printf "$(YELLOW)  ⚠  skipping validation checks (--fast enabled)$(NC)\n"
	@$(EXEC) sudo nixos-rebuild switch $(NIX_OPTS) --flake $(FLAKE_DIR)#$(HOSTNAME) --fast
ifndef EMBEDDED
	@printf "\n$(GREEN)  ✓ done$(NC)\n"
	@printf "\n$(YELLOW)📋 Quick Actions:$(NC)\n"
	@printf "$(DIM)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "  • verify no errors: $(BLUE)make log-err$(NC)\n"
	@printf "  • rollback if needed: $(BLUE)make gen-rollback$(NC)\n"
	@printf "  • run full checks next time: $(BLUE)make sys-apply-safe$(NC)\n\n"
endif

# ═══════════════════════════════════════════════════════════════
# 🧪 SYS-TEST - Activate configuration temporarily until reboot
# ═══════════════════════════════════════════════════════════════
# ──── Test: nixos-rebuild test — reverts on next reboot ──────
sys-test: ## Test configuration without permanent activation
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)🧪 sys-test · activate until reboot$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
endif
	@printf "  building system closure...\n"
	@$(EXEC) sudo nixos-rebuild test $(NIX_OPTS) --flake $(FLAKE_DIR)#$(HOSTNAME)
ifndef EMBEDDED
	@printf "\n$(GREEN)  ✓ done$(NC)\n"
	@printf "\n$(YELLOW)📋 Quick Actions:$(NC)\n"
	@printf "$(DIM)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "  • make permanent: $(BLUE)make sys-apply$(NC)\n"
	@printf "  • reboot to revert: $(BLUE)systemctl reboot$(NC)\n"
	@printf "  • rollback generation: $(BLUE)make gen-rollback$(NC)\n\n"
endif

# ═══════════════════════════════════════════════════════════════
# 🔨 SYS-BUILD - Compile configuration without activating
# ═══════════════════════════════════════════════════════════════
# ──── Build: Compiles derivation, no switch — tracks duration ─
sys-build: ## Build configuration without switching
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)🔨 sys-build · compile, no switch$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
endif
	@printf "  compiling system derivation...\n"
	@START=$$(date +%s); \
	if [ "$$DRY_RUN" = "1" ]; then \
		printf "  ▶ [dry-run] sudo nixos-rebuild build $(NIX_OPTS) --flake $(FLAKE_DIR)#$(HOSTNAME)\n"; \
		BUILD_EXIT=0; \
	else \
		sudo nixos-rebuild build $(NIX_OPTS) --flake $(FLAKE_DIR)#$(HOSTNAME); \
		BUILD_EXIT=$$?; \
	fi; \
	END=$$(date +%s); \
	DURATION=$$((END - START)); \
	MINUTES=$$((DURATION / 60)); \
	SECS=$$((DURATION % 60)); \
	if [ $$BUILD_EXIT -eq 0 ]; then \
		if [ $$MINUTES -gt 0 ]; then \
			printf "$(GREEN)  ✓ success$(NC)  $(DIM)$${MINUTES}m $${SECS}s$(NC)\n"; \
		else \
			printf "$(GREEN)  ✓ success$(NC)  $(DIM)$${SECS}s$(NC)\n"; \
		fi; \
	else \
		printf "$(RED)  ✗ failed$(NC)  $(DIM)$${DURATION}s$(NC)\n"; \
	fi; \
	exit $$BUILD_EXIT
ifndef EMBEDDED
	@printf "\n$(GREEN)  ✓ done$(NC)\n"
	@printf "\n$(YELLOW)📋 Quick Actions:$(NC)\n"
	@printf "$(DIM)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "  • activate the build: $(BLUE)make sys-apply$(NC)\n"
	@printf "  • validate before switching: $(BLUE)make sys-check$(NC)\n"
	@printf "  • test temporarily: $(BLUE)make sys-test$(NC)\n\n"
endif

# ═══════════════════════════════════════════════════════════════
# 🔍 SYS-DRY-RUN - Preview what nixos-rebuild would build
# ═══════════════════════════════════════════════════════════════
# ──── Dry Run: nixos-rebuild dry-run — no build, no switch ───
sys-dry-run: ## Preview what would change without building
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)🔍 sys-dry-run · preview build plan$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
endif
	@printf "  calculating build plan...\n\n"
	@sudo nixos-rebuild dry-run $(NIX_OPTS) --flake $(FLAKE_DIR)#$(HOSTNAME)
ifndef EMBEDDED
	@printf "\n$(GREEN)  ✓ done$(NC)\n"
	@printf "\n$(YELLOW)📋 Quick Actions:$(NC)\n"
	@printf "$(DIM)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "  • build it: $(BLUE)make sys-build$(NC)\n"
	@printf "  • apply it: $(BLUE)make sys-apply$(NC)\n"
	@printf "  • validate first: $(BLUE)make sys-check$(NC)\n\n"
endif

# ═══════════════════════════════════════════════════════════════
# 🥾 SYS-BOOT - Set configuration as default for next boot
# ═══════════════════════════════════════════════════════════════
# ──── Boot: nixos-rebuild boot — activates on next reboot ────
sys-boot: ## Build and set as default for next boot (no immediate switch)
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)🥾 sys-boot · set default for next boot$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
endif
	@printf "  building and writing to bootloader...\n"
	@$(EXEC) sudo nixos-rebuild boot $(NIX_OPTS) --flake $(FLAKE_DIR)#$(HOSTNAME)
ifndef EMBEDDED
	@printf "\n$(GREEN)  ✓ done$(NC)\n"
	@printf "\n$(YELLOW)📋 Quick Actions:$(NC)\n"
	@printf "$(DIM)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "  • reboot to activate: $(BLUE)systemctl reboot$(NC)\n"
	@printf "  • apply immediately instead: $(BLUE)make sys-apply$(NC)\n"
	@printf "  • check generations: $(BLUE)make gen-list$(NC)\n\n"
endif

# ═══════════════════════════════════════════════════════════════
# 🔍 SYS-CHECK - Validate flake syntax, config eval, statix lint
# ═══════════════════════════════════════════════════════════════
# ──── Check: Three-step validation before applying changes ───
sys-check: ## Validate configuration before applying
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)🔍 sys-check · validate configuration$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
endif
ifeq ($(DRY_RUN),1)
	@printf "$(DIM)  ▶ [dry-run] skipping nix eval checks$(NC)\n"
else
	@printf "  flake syntax...              "
	@if nix flake check $(FLAKE_DIR) >/dev/null 2>&1; then \
		printf "$(GREEN)✓$(NC)\n"; \
	else \
		printf "$(RED)✗$(NC)\n"; \
		nix flake check $(FLAKE_DIR); \
		exit 1; \
	fi
	@printf "  config evaluation...         "
	@if nix eval .#nixosConfigurations.$(HOSTNAME).config.system.build.toplevel >/dev/null 2>&1; then \
		printf "$(GREEN)✓$(NC)\n"; \
	else \
		printf "$(RED)✗$(NC)\n"; \
		nix eval .#nixosConfigurations.$(HOSTNAME).config.system.build.toplevel --show-trace; \
		exit 1; \
	fi
	@printf "  statix lint...               "
	@if command -v statix >/dev/null 2>&1; then \
		if statix check . >/dev/null 2>&1; then \
			printf "$(GREEN)✓$(NC)\n"; \
		else \
			printf "$(YELLOW)⚠  warnings (make fmt-lint)$(NC)\n"; \
		fi; \
	else \
		printf "$(DIM)⊘ not installed$(NC)\n"; \
	fi
endif
ifndef EMBEDDED
	@printf "\n$(GREEN)  ✓ done$(NC)\n"
	@printf "\n$(YELLOW)📋 Quick Actions:$(NC)\n"
	@printf "$(DIM)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "  • apply after check: $(BLUE)make sys-apply$(NC)\n"
	@printf "  • safe apply (check + switch): $(BLUE)make sys-apply-safe$(NC)\n"
	@printf "  • fix lint warnings: $(BLUE)make fmt-lint$(NC)\n\n"
endif

# ═══════════════════════════════════════════════════════════════
# 🐛 SYS-DEBUG - Rebuild with --show-trace and --verbose
# ═══════════════════════════════════════════════════════════════
# ──── Debug: Full verbosity for diagnosing build failures ────
sys-debug: ## Rebuild with verbose output and trace
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)🐛 sys-debug · verbose rebuild$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
endif
	@printf "  launching verbose rebuild with full trace...\n\n"
	@sudo nixos-rebuild switch $(NIX_OPTS) --flake $(FLAKE_DIR)#$(HOSTNAME) --show-trace --verbose

# ═══════════════════════════════════════════════════════════════
# 🚨 SYS-FORCE - Emergency rebuild with eval cache disabled
# ═══════════════════════════════════════════════════════════════
# ──── Force: Disables cache, full trace — use as last resort ─
sys-force: ## Emergency rebuild with maximum verbosity
ifndef EMBEDDED
	@printf "\n"
	@printf "$(RED)🚨 sys-force · emergency rebuild$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
endif
	@printf "$(YELLOW)  ⚠  disabling eval cache, enabling full trace$(NC)\n\n"
	@sudo nixos-rebuild switch \
		$(NIX_OPTS) \
		--option eval-cache false \
		--flake $(FLAKE_DIR)#$(HOSTNAME) \
		--show-trace --verbose
ifndef EMBEDDED
	@printf "\n$(GREEN)  ✓ done$(NC)\n"
	@printf "\n$(YELLOW)📋 Quick Actions:$(NC)\n"
	@printf "$(DIM)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "  • verify no errors: $(BLUE)make log-err$(NC)\n"
	@printf "  • rollback if needed: $(BLUE)make gen-rollback$(NC)\n"
	@printf "  • check new generation: $(BLUE)make gen-list$(NC)\n\n"
endif


# === Maintenance and Utilities ===

# ═══════════════════════════════════════════════════════════════
# 👨‍⚕️ SYS-DOCTOR - Fix common permission issues in user dirs
# ═══════════════════════════════════════════════════════════════
# ──── Doctor: Repairs ~/.config and ~/.local ownership ───────
sys-doctor: ## Fix common permission issues
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)👨‍⚕️ sys-doctor · fix permissions$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
endif
	@printf "  ~/.config ownership...  "
	@if [ -d ~/.config ]; then \
		if find ~/.config -maxdepth 1 -not -user $$USER 2>/dev/null | grep -q .; then \
			printf "$(YELLOW)fixing...$(NC) "; \
			if sudo chown -R $$USER:users ~/.config 2>/dev/null; then \
				printf "$(GREEN)✓$(NC)\n"; \
			else \
				printf "$(RED)✗$(NC)\n"; \
			fi; \
		else \
			printf "$(GREEN)✓$(NC)\n"; \
		fi; \
	else \
		printf "$(YELLOW)⚠  not found$(NC)\n"; \
	fi
	@printf "  ~/.local ownership...   "
	@if [ -d ~/.local ]; then \
		if find ~/.local -maxdepth 1 -not -user $$USER 2>/dev/null | grep -q .; then \
			printf "$(YELLOW)fixing...$(NC) "; \
			if sudo chown -R $$USER:users ~/.local 2>/dev/null; then \
				printf "$(GREEN)✓$(NC)\n"; \
			else \
				printf "$(RED)✗$(NC)\n"; \
			fi; \
		else \
			printf "$(GREEN)✓$(NC)\n"; \
		fi; \
	else \
		printf "$(YELLOW)⚠  not found$(NC)\n"; \
	fi
ifndef EMBEDDED
	@printf "\n$(GREEN)  ✓ done$(NC)\n"
	@printf "\n$(YELLOW)📋 Quick Actions:$(NC)\n"
	@printf "$(DIM)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "  • fix git ownership too: $(BLUE)make sys-fix-git$(NC)\n"
	@printf "  • full deploy cycle: $(BLUE)make sys-deploy$(NC)\n"
	@printf "  • apply system: $(BLUE)make sys-apply$(NC)\n\n"
endif

# ═══════════════════════════════════════════════════════════════
# 🔧 SYS-FIX-GIT - Repair .git object ownership in flake dir
# ═══════════════════════════════════════════════════════════════
# ──── Fix Git: Repairs FLAKE_DIR/.git ownership for git ops ──
sys-fix-git: ## Fix git repo ownership issues in flake dir
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)🔧 sys-fix-git · repair git ownership$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
endif
	@printf "  $(FLAKE_DIR)/.git ownership...  "
	@if [ -d "$(FLAKE_DIR)/.git/objects" ]; then \
		if find "$(FLAKE_DIR)/.git/objects" -maxdepth 2 -type d -not -user $$USER 2>/dev/null | grep -q .; then \
			printf "$(YELLOW)fixing...$(NC) "; \
			if sudo chown -R $$USER:users "$(FLAKE_DIR)/.git" 2>/dev/null; then \
				printf "$(GREEN)✓$(NC)\n"; \
			else \
				printf "$(RED)✗$(NC)\n"; \
			fi; \
		else \
			printf "$(GREEN)✓$(NC)\n"; \
		fi; \
	else \
		printf "$(YELLOW)⚠  no git repo at $(FLAKE_DIR)$(NC)\n"; \
	fi
ifndef EMBEDDED
	@printf "\n$(GREEN)  ✓ done$(NC)\n"
	@printf "\n$(YELLOW)📋 Quick Actions:$(NC)\n"
	@printf "$(DIM)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "  • stage and commit: $(BLUE)make git-add-commit$(NC)\n"
	@printf "  • full deploy cycle: $(BLUE)make sys-deploy$(NC)\n"
	@printf "  • fix user dirs too: $(BLUE)make sys-doctor$(NC)\n\n"
endif

# ═══════════════════════════════════════════════════════════════
# 📋 SYS-COPY-HW-CONFIG - Backup hardware-configuration.nix
# ═══════════════════════════════════════════════════════════════
# ──── Copy HW: Copies /etc/nixos configs to repo with chown ──
sys-copy-hw-config: ## Copy hardware config to Dotfiles
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)📋 sys-copy-hw-config · backup hardware config$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
endif
	@printf "  copying from /etc/nixos → $(FLAKE_DIR)...\n"
	@sudo cp /etc/nixos/hardware-configuration.nix $(FLAKE_DIR)/hardware-configuration.nix
	@sudo chown $$USER:users $(FLAKE_DIR)/hardware-configuration.nix
	@sudo cp /etc/nixos/configuration.nix $(FLAKE_DIR)/configuration.nix
	@sudo chown $$USER:users $(FLAKE_DIR)/configuration.nix
	@printf "$(GREEN)  ✓ hardware-configuration.nix$(NC)\n"
	@printf "$(GREEN)  ✓ configuration.nix$(NC)\n"
	@printf "$(DIM)  permissions set to $$USER$(NC)\n"
ifndef EMBEDDED
	@printf "\n$(GREEN)  ✓ done$(NC)\n"
	@printf "\n$(YELLOW)📋 Quick Actions:$(NC)\n"
	@printf "$(DIM)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "  • commit the backup: $(BLUE)make git-add-commit$(NC)\n"
	@printf "  • apply updated config: $(BLUE)make sys-apply$(NC)\n"
	@printf "  • rescan hardware instead: $(BLUE)make sys-hw-scan$(NC)\n\n"
endif

# ═══════════════════════════════════════════════════════════════
# 🔧 SYS-HW-SCAN - Generate fresh hardware-configuration.nix
# ═══════════════════════════════════════════════════════════════
# ──── HW Scan: nixos-generate-config — saves to hosts dir ────
sys-hw-scan: ## Re-scan hardware configuration
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)🔧 sys-hw-scan · detect hardware$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
endif
	@printf "  scanning host $(HOSTNAME)...\n"
	@sudo nixos-generate-config --show-hardware-config > hosts/$(HOSTNAME)/hardware-configuration-new.nix
	@printf "$(GREEN)  ✓ saved to hosts/$(HOSTNAME)/hardware-configuration-new.nix$(NC)\n\n"
	@printf "$(YELLOW)  ⚠  review before applying:$(NC)\n"
	@printf "  diff:  $(BLUE)diff hosts/$(HOSTNAME)/hardware-configuration{.nix,-new.nix}$(NC)\n"
	@printf "  apply: $(BLUE)mv hosts/$(HOSTNAME)/hardware-configuration-new.nix hosts/$(HOSTNAME)/hardware-configuration.nix$(NC)\n"
ifndef EMBEDDED
	@printf "\n$(GREEN)  ✓ done$(NC)\n"
	@printf "\n$(YELLOW)📋 Quick Actions:$(NC)\n"
	@printf "$(DIM)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "  • apply after review: $(BLUE)make sys-apply$(NC)\n"
	@printf "  • commit hw config: $(BLUE)make git-add-commit$(NC)\n"
	@printf "  • copy from /etc/nixos instead: $(BLUE)make sys-copy-hw-config$(NC)\n\n"
endif
