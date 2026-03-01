# ============================================================================
# Git y Respaldo
# ============================================================================
# Description: Targets for git operations, commits and backup
# Documentation: docs/src/content/docs/makefile/06-git.mdx
# Targets: 7 targets
# ============================================================================

.PHONY: git-add git-commit git-add-commit git-push git-status git-diff git-log

# === Git and Publishing ===

git-add: ## Stage all changes for git
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(CYAN)             💾 Git Stage Changes                       \n$(NC)"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
	
	@printf "$(GREEN)1.$(NC) $(BLUE)Staging Status:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
endif
	@CHANGED=$$(git status --short | wc -l); \
	if [ $$CHANGED -gt 0 ]; then \
		printf "$(BLUE)Adding all changes to staging area...$(NC)\n"; \
		git add .; \
		printf "$(GREEN)✓ Staged $$CHANGED file(s)$(NC)\n"; \
		printf "\n$(BLUE)Changes staged:$(NC)\n"; \
		git status --short | sed 's/^/  /'; \
	else \
		printf "$(YELLOW)⚠️  No changes to stage$(NC)\n"; \
		printf "$(BLUE)Working tree is clean.$(NC)\n"; \
	fi
	
ifndef EMBEDDED
	@printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(GREEN) ✅ Staging complete$(NC)\n"
	@printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif

git-commit: ## Quick commit with timestamp
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(CYAN)             📝 Git Quick Commit                        \n$(NC)"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
	
	@printf "$(GREEN)1.$(NC) $(BLUE)Committing:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
endif
	@if [ -n "$$(git status --porcelain)" ]; then \
		printf "$(BLUE)Staging changes...$(NC)\n"; \
		git add .; \
		COMMIT_MSG="config: update $$(date '+%Y-%m-%d %H:%M:%S')"; \
		printf "$(BLUE)Creating commit:$(NC) $(GREEN)$$COMMIT_MSG$(NC)\n\n"; \
		git commit -m "$$COMMIT_MSG" || exit 1; \
		COMMIT_HASH=$$(git rev-parse --short HEAD); \
		BRANCH=$$(git branch --show-current); \
		printf "\n$(GREEN)✓ Commit created successfully$(NC)\n"; \
		printf "$(BLUE)Hash:$(NC) $(GREEN)$$COMMIT_HASH$(NC)\n"; \
		printf "$(BLUE)Branch:$(NC) $(GREEN)$$BRANCH$(NC)\n"; \
	else \
		printf "$(YELLOW)⚠️  No changes to commit$(NC)\n"; \
		printf "$(BLUE)Working tree is clean. Proceeding...$(NC)\n"; \
	fi
	
ifndef EMBEDDED
	@printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(GREEN) ✅ Commit operation finished$(NC)\n"
	@printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif

git-add-commit: ## Stage and commit all changes together
	@$(MAKE) -s git-add
	@$(MAKE) -s git-commit

git-push: ## Push to remote using GitHub CLI
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(CYAN)             ☁️  Git Push to Remote                      \n$(NC)"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
	
	@printf "$(GREEN)1.$(NC) $(BLUE)Syncing with Remote:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
endif
	@BRANCH=$$(git branch --show-current); \
	REMOTE=$$(git remote get-url origin 2>/dev/null | sed -E 's|.*github.com[:/]([^/]+/[^/]+)(\.git)?$$|\1|' | sed 's|\.git$$||'); \
	printf "$(BLUE)Branch:$(NC) $(GREEN)$$BRANCH$(NC)\n"; \
	printf "$(BLUE)Remote:$(NC) $(GREEN)$$REMOTE$(NC)\n\n"; \
	UNPUSHED=$$(git log origin/$$BRANCH..HEAD --oneline 2>/dev/null | wc -l); \
	if [ $$UNPUSHED -gt 0 ]; then \
		printf "$(BLUE)Pushing $$UNPUSHED commit(s)...$(NC)\n"; \
		git push || exit 1; \
		printf "\n$(GREEN)✓ Successfully pushed to remote$(NC)\n"; \
	else \
		printf "$(YELLOW)⚠️  Everything up-to-date (no changes to push)$(NC)\n"; \
	fi
	
ifndef EMBEDDED
	@printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(GREEN) ✅ Push complete$(NC)\n"
	@printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif

git-status: ## Show git status with GitHub CLI
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(CYAN)             📊 Git Repository Status                   \n$(NC)"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
	
	@printf "$(GREEN)1.$(NC) $(BLUE)Configuration:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
endif
	@printf "  $(BLUE)Host:$(NC)  $(HOSTNAME)\n"
	@printf "  $(BLUE)Flake:$(NC) $(PWD)\n"
	@printf "  $(BLUE)NixOS:$(NC) $$(nixos-version 2>/dev/null | cut -d' ' -f1 || echo 'N/A')\n"
	
	@printf "\n$(GREEN)2.$(NC) $(BLUE)Git Status:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
	@if git rev-parse --git-dir > /dev/null 2>&1; then \
		printf "  $(BLUE)Repository:$(NC) "; \
		REMOTE_URL=$$(git remote get-url origin 2>/dev/null); \
		if [ -n "$$REMOTE_URL" ]; then \
			REPO_NAME=$$(echo "$$REMOTE_URL" | sed -E 's|.*github.com[:/]([^/]+/[^/]+)(\.git)?$$|\1|' | sed 's|\.git$$||'); \
			if [ -n "$$REPO_NAME" ]; then \
				printf "$$REPO_NAME\n"; \
			else \
				printf "$$REMOTE_URL\n"; \
			fi; \
		else \
			printf "$(YELLOW)No remote configured$(NC)\n"; \
		fi; \
		printf "  $(BLUE)Branch:$(NC)     $$(git branch --show-current)\n"; \
		printf "  $(BLUE)Status:$(NC)     "; \
		if git diff-index --quiet HEAD -- 2>/dev/null; then \
			printf "$(GREEN)Clean$(NC)\n"; \
		else \
			printf "$(YELLOW)Uncommitted changes$(NC)\n"; \
		fi; \
		printf "\n$(GREEN)3.$(NC) $(BLUE)Local Changes:$(NC)\n"; \
		printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"; \
		git status --short | sed 's/^/  /'; \
		printf "\n$(GREEN)4.$(NC) $(BLUE)Recent Commits:$(NC)\n"; \
		printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"; \
		git log --max-count=3 --pretty=format:"  %C(green)%h%C(reset)  %<(50,trunc)%s  %C(blue)%<(15)%ar%C(reset)" 2>/dev/null; \
	else \
		printf "$(YELLOW)Not a git repository$(NC)\n"; \
	fi
	
ifndef EMBEDDED
	@printf "\n\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(GREEN) ✅ Status report complete$(NC)\n"
	@printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif

git-diff: ## Show uncommitted changes to .nix configuration files
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(CYAN)             🔄 Git Configuration Changes               \n$(NC)"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
	
	@printf "$(GREEN)1.$(NC) $(BLUE)Diff Analysis:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
endif
	@if git diff --quiet -- '*.nix' 2>/dev/null; then \
		printf "$(GREEN)✓ No uncommitted changes to .nix files$(NC)\n"; \
		printf "$(BLUE)All configuration files are clean.$(NC)\n"; \
	else \
		printf "$(BLUE)Uncommitted changes in .nix files:$(NC)\n\n"; \
		CHANGED_FILES=$$(git diff --name-only -- '*.nix' 2>/dev/null | wc -l); \
		ADDED_LINES=$$(git diff --numstat -- '*.nix' 2>/dev/null | awk '{sum+=$$1} END {print sum+0}'); \
		DELETED_LINES=$$(git diff --numstat -- '*.nix' 2>/dev/null | awk '{sum+=$$2} END {print sum+0}'); \
		printf "$(PURPLE)Summary:$(NC)\n"; \
		printf "  • $(BLUE)Files changed:$(NC) $(GREEN)$$CHANGED_FILES$(NC)\n"; \
		if [ -n "$$ADDED_LINES" ] && [ "$$ADDED_LINES" != "0" ]; then \
			printf "  • $(BLUE)Lines added:$(NC) $(GREEN)+$$ADDED_LINES$(NC)\n"; \
		fi; \
		if [ -n "$$DELETED_LINES" ] && [ "$$DELETED_LINES" != "0" ]; then \
			printf "  • $(BLUE)Lines deleted:$(NC) $(RED)-$$DELETED_LINES$(NC)\n"; \
		fi; \
		printf "\n$(GREEN)2.$(NC) $(BLUE)File Changes:$(NC)\n"; \
		printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"; \
		git diff --stat --color=always -- '*.nix' 2>/dev/null || git diff --stat -- '*.nix'; \
		printf "\n$(GREEN)3.$(NC) $(BLUE)Detailed Diff:$(NC)\n"; \
		printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"; \
		git diff --color=always -- '*.nix' 2>/dev/null || git diff -- '*.nix'; \
	fi
	
ifndef EMBEDDED
	@printf "\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(GREEN) ✅ Diff complete$(NC)\n"
	@printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif

git-log: ## Show recent changes from git log
ifndef EMBEDDED
	@printf "\n"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(CYAN)             📜 Recent Git History                      \n$(NC)"
	@printf "$(CYAN)═════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
	
	@printf "$(GREEN)1.$(NC) $(BLUE)Recent Commits:$(NC)\n"
	@printf "$(CYAN)────────────────────────────────────────────────────────────────────────────────$(NC)\n"
endif
	@if git rev-parse --git-dir > /dev/null 2>&1; then \
		git log --max-count=15 --pretty=format:"  %C(green)%h%C(reset)  %<(58,trunc)%s  %C(blue)%<(15)%ar%C(reset)" 2>/dev/null; \
	else \
		printf "$(YELLOW)Not a git repository$(NC)\n"; \
	fi
	
ifndef EMBEDDED
	@printf "\n\n$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "$(GREEN) ✅ Log complete$(NC)\n"
	@printf "$(CYAN)════════════════════════════════════════════════════════════════════════════════\n$(NC)"
	@printf "\n"
endif
