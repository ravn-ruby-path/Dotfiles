# ═══════════════════════════════════════════════════════════════
# 🔬 DEVELOPMENT TOOLS - Package search and analysis
# ═══════════════════════════════════════════════════════════════
# 📚 Documentation: docs/src/content/docs/makefile/08-dev.mdx
# 🎯 Purpose: Host listing, package search, REPL, shell, VM and closure analysis
# ──── Overview: 7 targets for development and inspection tasks ────
#
# 🧪 Dry Run (preview without executing):
#    make dev-repl   DRY_RUN=1
#    make dev-shell  DRY_RUN=1
#    make dev-vm     DRY_RUN=1

.PHONY: dev-hosts dev-search dev-search-inst dev-repl dev-shell dev-vm dev-size

# ──── Dry Run: make <target> DRY_RUN=1 to preview without executing ─
DRY_RUN ?= 0
export DRY_RUN
ifeq ($(DRY_RUN),1)
  EXEC = echo "  ▶ [dry-run]"
else
  EXEC =
endif

# === Analysis and Development ===

# ═══════════════════════════════════════════════════════════════
# 🖥️  DEV-HOSTS - List all host configurations defined in the flake
# ═══════════════════════════════════════════════════════════════
# ──── Hosts: Scans hosts/ directory for NixOS configuration names ──
dev-hosts: ## List all available hosts
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)🖥️  dev-hosts · nixos hosts in flake$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
endif
	@if [ -d "hosts" ]; then \
		find hosts -maxdepth 1 -mindepth 1 -type d -not -path '*/.*' | sed 's|^hosts/|  • |'; \
	else \
		printf "$(RED)  ✗ hosts/ directory not found$(NC)\n"; \
	fi
ifndef EMBEDDED
	@printf "\n$(GREEN)  ✓ done$(NC)\n"
endif
	@printf "\n$(YELLOW)📋 Quick Actions:$(NC)\n"
	@printf "$(DIM)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "  • deploy a host: $(BLUE)make sys-apply HOSTNAME=<name>$(NC)\n\n"

# ═══════════════════════════════════════════════════════════════
# 🔍 DEV-SEARCH - Search nixpkgs for a package
# ═══════════════════════════════════════════════════════════════
# ──── Search: nix search nixpkgs <pkg>; requires PKG=name ────
dev-search: ## Search nixpkgs for package (use PKG=name)
	@if [ -z "$(PKG)" ]; then \
		printf "$(RED)  ✗ PKG is required — usage: make dev-search PKG=<name>$(NC)\n"; \
		exit 1; \
	fi
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)🔍 dev-search · nixpkgs search$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
endif
	@nix search nixpkgs $(PKG)
ifndef EMBEDDED
	@printf "\n$(GREEN)  ✓ done$(NC)\n"
endif
	@printf "\n$(YELLOW)📋 Quick Actions:$(NC)\n"
	@printf "$(DIM)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "  • search installed packages: $(BLUE)make dev-search-inst PKG=$(PKG)$(NC)\n\n"

# ═══════════════════════════════════════════════════════════════
# 🔍 DEV-SEARCH-INST - Search among already-installed packages
# ═══════════════════════════════════════════════════════════════
# ──── Installed search: PATH, nix-env, current-system, HM profiles ─
# Search for a package in currently installed system/user profiles
dev-search-inst: ## Search installed packages (use PKG=name)
	@if [ -z "$$(PKG)" ]; then \
		printf "\n"; \
		printf "$(RED)❌ Error: PKG parameter is required$(NC)\n"; \
		printf "$(YELLOW)Usage: make dev-search-inst PKG=<package-name>$(NC)\n"; \
		exit 1; \
	fi

ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(CYAN)             🔍 Searching Installed Packages            \n$(NC)"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif
	
	@printf "$(GREEN)1.$(NC) $(BLUE)In PATH (which):$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@PKG_PATH=$$(which $(PKG) 2>/dev/null || true); \
	if [ -n "$$PKG_PATH" ]; then \
		printf "  $(GREEN)✓ Found:$(NC) $$PKG_PATH\n"; \
		PKG_STORE_PATH=$$(readlink -f "$$PKG_PATH" 2>/dev/null || true); \
		if [ -n "$$PKG_STORE_PATH" ]; then \
			printf "  $(BLUE)Store path:$(NC) $$PKG_STORE_PATH\n"; \
		fi; \
	else \
		printf "  $(YELLOW)Not found in PATH$(NC)\n"; \
	fi
	
	@printf "\n$(GREEN)2.$(NC) $(BLUE)User environment (nix-env):$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@USER_PKGS=$$(nix-env -q 2>/dev/null | grep -i "$(PKG)" || true); \
	if [ -n "$$USER_PKGS" ]; then \
		echo "$$USER_PKGS" | sed 's/^/  /'; \
	else \
		printf "  $(YELLOW)Not found$(NC)\n"; \
	fi
	
	@printf "\n$(GREEN)3.$(NC) $(BLUE)System packages (current-system):$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@SYSTEM_PKGS=$$(nix-store -q --references /run/current-system 2>/dev/null | grep -i "$(PKG)" | head -10 || true); \
	if [ -n "$$SYSTEM_PKGS" ]; then \
		echo "$$SYSTEM_PKGS" | sed 's/^/  /'; \
	else \
		printf "  $(YELLOW)Not found$(NC)\n"; \
	fi
	
	@printf "\n$(GREEN)4.$(NC) $(BLUE)Home Manager profiles:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@if [ -d "/etc/profiles/per-user" ]; then \
		HM_PKGS=$$(find /etc/profiles/per-user -name "$(PKG)" -type f 2>/dev/null | head -5 || true); \
		if [ -n "$$HM_PKGS" ]; then \
			echo "$$HM_PKGS" | sed 's/^/  /'; \
		else \
			printf "  $(YELLOW)Not found$(NC)\n"; \
		fi; \
	else \
		printf "  $(YELLOW)Home Manager profiles not found$(NC)\n"; \
	fi
	
ifndef EMBEDDED
	@printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(GREEN) ✅ Search complete$(NC)\n"
	@printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif

# ═══════════════════════════════════════════════════════════════
# 🧠 DEV-REPL - Open an interactive Nix REPL with the flake loaded
# ═══════════════════════════════════════════════════════════════
# ──── REPL: nix repl with repl-flake flag; inspect config live ────
# Start nix repl with the current flake loaded
dev-repl: ## Start nix repl with flake
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(CYAN)             🧠 Nix REPL - Interactive Shell            \n$(NC)"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif
	
	@printf "$(GREEN)1.$(NC) $(BLUE)Starting REPL:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@printf "$(BLUE)Loading flake environment...$(NC)\n"
	@printf "$(YELLOW)Useful commands:$(NC)\n"
	@printf "  $(GREEN):q$(NC) or $(GREEN):quit$(NC) - Exit REPL\n"
	@printf "  $(GREEN)outputs$(NC) - View flake outputs\n"
	@printf "  $(GREEN)outputs.nixosConfigurations.$(HOSTNAME)$(NC) - View configuration\n"
	@printf "\n"
	@nix repl --extra-experimental-features repl-flake $(FLAKE_DIR)
	
ifndef EMBEDDED
	@printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(GREEN) ✅ REPL session ended$(NC)\n"
	@printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif

# ═══════════════════════════════════════════════════════════════
# 🐚 DEV-SHELL - Enter the flake development shell
# ═══════════════════════════════════════════════════════════════
# ──── Shell: nix develop or nix-shell fallback ───────────────────
# Enter a development shell (uses flake's devShells or basic nix-shell)
dev-shell: ## Enter development shell
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(CYAN)             🐚 Development Shell                       \n$(NC)"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif
	
	@printf "$(GREEN)1.$(NC) $(BLUE)Activating Shell:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@if nix flake show $(FLAKE_DIR) 2>/dev/null | grep -q "devShells"; then \
		printf "$(BLUE)Entering development shell (nix develop)...$(NC)\n"; \
		nix develop $(FLAKE_DIR); \
	else \
		printf "$(YELLOW)⚠️  No devShells configured in flake, using nix-shell...$(NC)\n"; \
		nix-shell; \
	fi
	
ifndef EMBEDDED
	@printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(GREEN) ✅ Shell session ended$(NC)\n"
	@printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif

# ═══════════════════════════════════════════════════════════════
# 🖥️  DEV-VM - Build and run a NixOS virtual machine for testing
# ═══════════════════════════════════════════════════════════════
# ──── VM: Builds then runs result/bin/run-*-vm; HOST=name optional ─
# Build and run a VM for testing configuration
dev-vm: ## Build and run VM (use HOST=name)
	@HOST=$${HOST:-$(HOSTNAME)}; \
	if [ -z "$(EMBEDDED)" ]; then \
		printf "\n"; \
		printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"; \
		printf "$(CYAN)             🖥️  NixOS Virtual Machine ($$HOST)         \n$(NC)"; \
		printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"; \
		printf "\n"; \
	fi; \
	printf "$(GREEN)1.$(NC) $(BLUE)Building VM:$(NC)\n"; \
	printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"; \
	printf "$(BLUE)Building VM from configuration for $$HOST...$(NC)\n"; \
	if nix build ".#nixosConfigurations.$$HOST.config.system.build.vm" 2>/dev/null; then \
		printf "$(GREEN)✅ VM built successfully$(NC)\n"; \
		printf "\n$(GREEN)2.$(NC) $(BLUE)Running VM:$(NC)\n"; \
		printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"; \
		printf "$(BLUE)Starting VM... (Press partial Ctrl+A then c to control, or close window to exit)$(NC)\n"; \
		./result/bin/run-*-vm; \
		if [ -z "$(EMBEDDED)" ]; then \
			printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"; \
			printf "$(GREEN) ✅ VM session ended$(NC)\n"; \
			printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"; \
			printf "\n"; \
		fi; \
	else \
		printf "\n$(RED)❌ VM build failed$(NC)\n"; \
		printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"; \
		printf "$(RED) ❌ Command failed$(NC)\n"; \
		printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"; \
		printf "\n"; \
		exit 1; \
	fi

# ═══════════════════════════════════════════════════════════════
# 📊 DEV-SIZE - Analyse closure size of a host or running system
# ═══════════════════════════════════════════════════════════════
# ──── Size: nix path-info -Sh; top 10 largest packages listed ────
# Show closure size of a host or current system
dev-size: ## Show closure size (use HOST=name)
	@HOST_PATH=$${HOST:+$(FLAKE_DIR)#nixosConfigurations.$$HOST.config.system.build.toplevel}; \
	HOST_PATH=$${HOST_PATH:-/run/current-system}; \
	if [ -z "$(EMBEDDED)" ]; then \
		printf "\n"; \
		printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"; \
		printf "$(CYAN)             📊 System Closure Size Analysis            \n$(NC)"; \
		printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"; \
		printf "\n"; \
	fi; \
	printf "$(GREEN)1.$(NC) $(BLUE)Total Size:$(NC)\n"; \
	printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"; \
	printf "$(BLUE)Closure size for $$HOST_PATH:$(NC)\n"; \
	nix path-info -Sh $$HOST_PATH; \
	printf "\n$(GREEN)2.$(NC) $(BLUE)Top 10 Largest Packages:$(NC)\n"; \
	printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"; \
	nix path-info -rSh $$HOST_PATH | sort -k2 -h | tail -10; \
	if [ -z "$(EMBEDDED)" ]; then \
	printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"; \
	printf "$(GREEN) ✅ Analysis complete$(NC)\n"; \
	printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"; \
	printf "\n"; \
	fi
