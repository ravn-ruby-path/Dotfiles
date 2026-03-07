# AI Agents Code Commenting Guide

This guide outlines the commenting standards for AI agents working on this NixOS dotfiles project. It ensures consistent, modern, and visually appealing code documentation.

## General Principles

- **Language**: All comments must be in English only. No Spanish or other languages.
- **Style**: Use structured, visual separators for organization.
- **Consistency**: Follow the established patterns across all files.
- **Purpose**: Comments should explain "why" and "what", not just "how".

## Section Headers

Use full-width separators with emojis for major sections:

```
# ═══════════════════════════════════════════════════════════════
# 🤖 AI TOOLS - UNRESTRICTED ACCESS PERMISSIONS CONFIGURATION
# ═══════════════════════════════════════════════════════════════
```

- Start with `# ═══════════════════════════════════════════════════════════════`
- Include emoji + descriptive title in CAPS
- End with `# ═══════════════════════════════════════════════════════════════`

## Inline Separators

Use centered separators for sub-sections and key blocks:

```
# ──── Sandbox Control ─────────────────────────────────────
```

- Format: `# ──── [Title] ────────────────────────────────`
- Keep titles concise and descriptive
- Use for grouping related configurations

## Simple Separators

Use simple equals separators for minor groupings within sections:

```
# === Maintenance and Utilities ===
```

- Format: `# === [Title] ===`
- Use for grouping related targets within larger sections
- Keep titles brief and descriptive
- Apply to Makefile targets and utility functions

## Comment Integration

Integrate redundant comments into separators to avoid duplication:

**Before:**
```
# ──── Sandbox Override ─────────────────────────────────────
# No sandboxing restrictions
SANDBOX = "false";
```

**After:**
```
# ──── Sandbox Override: No sandboxing restrictions ────────
SANDBOX = "false";
```

## Specific Rules by File Type

### Bash Scripts (.sh, bin/ scripts)

Every bash script in this project must follow the visual and structural language established in `git-setup.sh` and `bin/git-bare-clone`. This ensures all scripts are immediately recognizable as coming from the same author.

#### 1. ASCII Art Banner

Every script must open with a box-framed ASCII art banner using the `╭─╮` / `│` / `╰─╯` box-drawing characters. The banner includes:
- The script name in block letters (figlet-style)
- A one-line subtitle describing the script's purpose
- A blank padding line at top and bottom inside the box

```bash
#!/usr/bin/env bash
# ╭──────────────────────────────────────────────────────────────────────────────╮
# │                                                                              │
# │   ███████╗ ██████╗ ██████╗                                                  │
# │   ██╔════╝██╔═══██╗██╔══██╗                                                 │
# │   █████╗  ██║   ██║██████╔╝                                                 │
# │   ██╔══╝  ██║   ██║██╔══██╗                                                 │
# │   ██║     ╚██████╔╝██║  ██║                                                 │
# │   ╚═╝      ╚═════╝ ╚═╝  ╚═╝                                                 │
# │                                                                              │
# │              Short description of what the script does                      │
# │                                                                              │
# ╰──────────────────────────────────────────────────────────────────────────────╯
```

#### 2. Script Bootstrap

Immediately after the banner, declare the strict mode and trap:

```bash
set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT
```

#### 3. Section Boxes

Separate all major logical blocks with `┌─┐` / `│` / `└─┘` box headers. Keep all boxes the same width (80 chars total):

```bash
# ┌──────────────────────────────────────────────────────────────────────────────┐
# │ Configuration                                                                │
# └──────────────────────────────────────────────────────────────────────────────┘
```

Standard sections to include (in order):
1. `Configuration` — env vars, defaults, file paths
2. `Colors & Styling` — color constants + Nerd Font icons
3. `Helper Functions` — print_*, die, cleanup
4. `Usage` — usage() function
5. `Argument Parsing` — parse_params()
6. `Pre-flight Checks` — guard conditions, dependency checks
7. `Execution Steps` — main logic
8. `Summary` — final success output

#### 4. Colors

Declare all colors as `readonly` immediately after `set -Eeuo pipefail`. Always use the full standard palette:

```bash
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly GRAY='\033[0;90m'
readonly NC='\033[0m'
```

- `NC` (No Color) is always used to reset — never `NOFORMAT` or `RESET`
- Colors are always `readonly` — never re-assigned
- No runtime color detection via `[[ -t 2 ]]` — the palette is always defined

#### 5. Nerd Font Icons

Declare icons as `readonly` constants alongside colors. Use only icons from the Nerd Fonts set. Pick semantically appropriate icons for the script's domain:

```bash
# Nerd Font Icons
readonly ICON_CHECK=""
readonly ICON_CROSS=""
readonly ICON_ARROW=""
readonly ICON_WARN=""
readonly ICON_INFO=""
readonly ICON_GIT=""
readonly ICON_BRANCH=""
readonly ICON_FOLDER="󰉋"
readonly ICON_ROCKET="󱓞"
readonly ICON_GEAR="󰒓"
```

#### 6. Print Helper Functions

Every script must define the same set of print helpers. These functions are not optional — they form the visual contract of the script:

```bash
print_header() {
    echo ""
    echo -e "${CYAN}╭────────────────────────────────────────────────────────────╮${NC}"
    echo -e "${CYAN}│${NC}  ${WHITE}$1${NC}"
    echo -e "${CYAN}╰────────────────────────────────────────────────────────────╯${NC}"
}

print_section() {
    echo ""
    echo -e "${MAGENTA}  $1${NC}"
    echo -e "${GRAY}  ──────────────────────────────────────────────────────────${NC}"
}

print_step()    { echo -e "  ${GRAY}${ICON_ARROW}${NC} $1"; }
print_success() { echo -e "  ${GREEN}${ICON_CHECK}${NC} $1"; }
print_error()   { echo -e "  ${RED}${ICON_CROSS}${NC} $1" >&2; }
print_warn()    { echo -e "  ${YELLOW}${ICON_WARN}${NC} $1"; }
print_info()    { echo -e "  ${BLUE}${ICON_INFO}${NC} $1"; }
```

**Rules:**
- `print_header` — used at script start and for the final summary
- `print_section` — used for each numbered step or logical group
- `print_step` — used for sub-items within a section (loops, sub-actions)
- `print_success` / `print_error` / `print_warn` / `print_info` — used for status messages
- `print_error` always writes to stderr (`>&2`)
- Never use raw `echo` for user-facing messages — always use a print helper

#### 7. `die` and `cleanup` Functions

```bash
die() {
    print_error "$1"
    exit "${2-1}"
}

cleanup() {
    trap - SIGINT SIGTERM ERR EXIT
}
```

- `die` uses `print_error` internally — never raw `echo`
- `cleanup` must always be registered with `trap` at the top of the script

#### 8. Numbered Execution Steps

Multi-step scripts must number their steps using `print_section` with `[N/TOTAL]` notation:

```bash
# ── Step 1/5: Clone bare ──────────────────────────────────────────────────────
print_section "${ICON_CLONE} [1/5] Cloning bare repository"

# ── Step 2/5: Configure ──────────────────────────────────────────────────────
print_section "${ICON_GEAR} [2/5] Configuring remote fetch refs"
```

- Inline comment above each `print_section` uses `# ── Step N/T: Title ─────` format
- Total step count appears in every step (`[1/5]`, `[2/5]`, ...) — update if steps change
- Each section ends with a `print_success` confirming the step completed

#### 9. Usage Function

`usage()` must use print helpers and colored output — never a plain `cat <<EOF` block:

```bash
usage() {
    echo ""
    echo -e "${WHITE}Usage:${NC} $(basename "${BASH_SOURCE[0]}") ${GRAY}[-h] [-v]${NC} ${CYAN}<required-arg>${NC}"
    echo ""
    echo -e "  Description of what the script does."
    echo ""
    echo -e "${WHITE}Options:${NC}"
    echo -e "  ${CYAN}-h, --help${NC}     Print this help and exit"
    echo -e "  ${CYAN}-v, --verbose${NC}  Print script debug info"
    echo ""
    exit 0
}
```

#### 10. Final Summary

Every script must end with a `print_header` summary that confirms success and shows the user what was created or changed:

```bash
print_header "${ICON_ROCKET} All done"
echo -e "  ${CYAN}/path/to/result/${NC}"
for item in "${items[@]}"; do
    echo -e "  ${GREEN}${ICON_CHECK}${NC} ${WHITE}$item${NC}"
done
echo ""
print_info "Next step hint for the user"
echo ""
```

#### Visual Reference

The following files serve as the canonical style reference for bash scripts:
- [`bin/git-bare-clone`](bin/git-bare-clone) — multi-step script with numbered sections
- [`git-setup.sh`](git-setup.sh) — comprehensive script with all helper patterns

When in doubt, follow the patterns in these files exactly.

---

### Nix Modules (.nix files)

- **Headers**: Use ════════════════ with emojis for sections
- **Inline**: Use ──────────────── separators for sub-blocks
- **Simple**: Use === === separators for option groups within sections
- **Variables**: Comment complex variables with separators
- **Functions**: Explain purpose before definition

### Scripts and Configs

- **Headers**: Use ════════════════ for major blocks
- **Inline**: Use ──────────────── for steps or phases
- **Logic**: Comment non-obvious logic with separators

### Makefiles (.mk files)

- **Section Headers**: Use ════════════════ with emojis for major sections
- **Target Headers**: Use ════════════════ with emojis for individual make targets
- **Inline Separators**: Use ──────────────── for target descriptions and sub-steps
- **Simple Separators**: Use === === for grouping related targets within sections
- **Target Comments**: Each target should have a `##` comment for help system

## Examples

### Good Header
```
# ═══════════════════════════════════════════════════════════════
# 🚀 NETWORK CONFIGURATION - AGGRESSIVE DNS OVERRIDE
# ═══════════════════════════════════════════════════════════════
```

### Good Inline Separator
```
# ──── DNS Override ───────────────────────────────────────
insertNameservers = [ "1.1.1.1" ];
```

### Bad: Redundant Comments
```
# ──── DNS Override ───────────────────────────────────────
# Override DNS settings
insertNameservers = [ "1.1.1.1" ];  # Don't do this
```

### Good: Integrated Comment
```
# ──── DNS Override: Force custom servers over DHCP ──────
insertNameservers = [ "1.1.1.1" ];
```

### Simple Separator Example
```
# === Maintenance and Utilities ===
sys-doctor: ## Fix common permission issues
```

### Makefile Target Header Example
```
# ═══════════════════════════════════════════════════════════════
# 🛡️ SAFE DEPLOYMENT - Validate before applying changes
# ═══════════════════════════════════════════════════════════════
# ──── Safe Apply: Validate configuration before deployment ──
sys-apply-safe: sys-check sys-apply ## Validate then switch (safest option)
```

### Nix Options Group Example
```nix
options.modules.terminal.software.git = {
  enable = lib.mkEnableOption "Git with advanced configuration";

  # === User Identity ===
  userName = lib.mkOption {
    type = lib.types.str;
    default = "";
    description = "Your name for commits";
  };

  userEmail = lib.mkOption {
    type = lib.types.str;
    default = "";
    description = "Your email for commits";
  };

  # === Editor and Tools ===
  editor = lib.mkOption {
    type = lib.types.str;
    default = "nvim";
    description = "Editor for commits and rebases";
  };
};
```

### Before/After: Refactoring Nix Options
```nix
# BEFORE (verbose separators)
# ----------------------------------------------------------------------------
# User identity
# ----------------------------------------------------------------------------
userName = lib.mkOption { ... };

# ----------------------------------------------------------------------------
# Editor and tools
# ----------------------------------------------------------------------------
editor = lib.mkOption { ... };

# AFTER (concise separators)
# === User Identity ===
userName = lib.mkOption { ... };

# === Editor and Tools ===
editor = lib.mkOption { ... };
```

## Tools and Enforcement

- **Validation**: Run `make sys-check` after changes
- **Consistency**: Check existing files for patterns
- **Updates**: This guide should be updated as standards evolve

---

# Git Worktree Workflow

This section documents the bare-clone + worktree workflow used in this project. Any agent or contributor setting up the repo on a new machine **must** follow this workflow.

## Overview

Instead of a standard `git clone`, this project uses a **bare repository** pattern:

- Git objects are stored in `$BARE_HOME/<repo>/` — never touched directly
- Each branch is a separate directory (worktree) in `$WORKTREES_HOME/<repo>/`
- All worktrees share the same git objects, no need for `git stash` or `git checkout` to switch branches

```
~/.local/share/git-bare/Dotfiles/   ← bare objects (invisible)
~/Work/Dotfiles/
    ├── main/                        ← worktree (branch: main)
    ├── dev/                         ← worktree (branch: dev)
    ├── nix/                         ← worktree (branch: nix)
    ├── makefile/                    ← worktree (branch: makefile)
    ├── scripts/                     ← worktree (branch: scripts)
    └── ...
```

## Environment Variables

Set automatically by Home Manager (`modules.terminal.software.git`):

| Variable | Default | Purpose |
|---|---|---|
| `WORKTREES_HOME` | `~/Work` | Base directory for all worktrees |
| `BARE_HOME` | `~/.local/share/git-bare` | Base directory for bare repos |

Override in shell or per-command:
```bash
WORKTREES_HOME=~/Projects git-bare-clone git@github.com:user/repo.git
```

## Tools

### `git-bare-clone` — Bootstrap a repo

Clones a repository as bare and creates all worktrees in one command.

**Usage:**
```bash
git-bare-clone git@github.com:ravn-ruby-path/Dotfiles.git
```

**What it does (5 steps):**
1. Clones bare repo to `$BARE_HOME/<repo>/`
2. Configures `fetch = +refs/heads/*:refs/remotes/origin/*`
3. Fetches all remote tracking refs (`origin/*`)
4. Creates `$WORKTREES_HOME/<repo>/` with `.git` pointer
5. Creates one worktree per remote branch, each with upstream configured

**Flags:**
```bash
-w, --worktrees-dir <path>   Override worktrees base directory (one-off)
-v, --verbose                Debug output (set -x)
```

**Guards:**
- Fails if `$BARE_HOME/<repo>` already exists
- Fails if `$WORKTREES_HOME/<repo>` already exists

---

### `git-create-worktree` — Add a single worktree

Creates one worktree from an existing or new branch, with upstream tracking.

**Usage:**
```bash
# From inside the worktrees directory:
cd ~/Work/Dotfiles

# Existing branch (no upstream creation):
git-create-worktree -N -B <branch> -b <branch> <folder-name>

# New branch based on main:
git-create-worktree -b my-feature my-feature

# New branch with custom base:
git-create-worktree -B dev -b my-feature my-feature
```

**Flags:**
```bash
-b, --branch <name>     Branch name to create or checkout
-B, --base <name>       Base branch for new branches (default: origin/main)
-N, --no-create-upstream  Skip creating/setting upstream (use for existing branches)
-v, --verbose           Debug output
```

**Important:** Always run from the worktrees root directory (e.g. `~/Work/Dotfiles/`), not from inside a worktree.

---

### `make git-setup` — One-command bootstrap via Makefile

Wraps `git-bare-clone` as a Makefile target for use from within the project.

**Usage:**
```bash
cd ~/Work/Dotfiles/makefile
make git-setup REPO=git@github.com:user/repo.git
```

**Override locations:**
```bash
make git-setup REPO=... WORKTREES_HOME=~/Projects BARE_HOME=~/.git-bare
```

## Standard Development Workflow

### Setting up a new machine

```bash
# 1. Clone the Dotfiles (only manual step)
git-bare-clone git@github.com:ravn-ruby-path/Dotfiles.git

# 2. Apply Home Manager to get tools + session vars in PATH
cd ~/Work/Dotfiles/nix
home-manager switch --flake .

# 3. From now on, bootstrap any repo with one command
make -C ~/Work/Dotfiles/makefile git-setup REPO=git@github.com:user/other-repo.git
```

### Daily workflow

```bash
# Work on a branch — each branch is its own directory
cd ~/Work/Dotfiles/nix      # work on nix config
cd ~/Work/Dotfiles/makefile # work on makefile targets
cd ~/Work/Dotfiles/dev      # integration branch

# Standard git commands work normally in each worktree
git status
git pull
git add .
git commit -m "feat: ..."
git push
```

### Branch strategy

| Branch | Purpose | Merges to |
|---|---|---|
| `main` | Stable releases only | — |
| `dev` | Integration branch | `main` (via release PR) |
| `nix` | NixOS/HM modules | `dev` via PR |
| `makefile` | Makefile targets | `dev` via PR |
| `scripts` | Shell scripts + docs | `dev` via PR |
| `astro-site` | Documentation site | `dev` via PR |
| `minimal-installation` | Minimal system snapshot — **DO NOT MODIFY** | — |

**Rules:**
- Feature work happens in topic branches (`nix`, `scripts`, `makefile`, etc.)
- All merges to `dev` go through a Pull Request with detailed description
- `main` only receives merges from `dev` as versioned releases
- After merging to `dev`, sync all topic branches: `git pull --rebase origin dev`
- **`minimal-installation` must never be modified** — it is a protected snapshot of the minimum viable system. Adding packages or config to it defeats its purpose. Users who want the full system should use `main`.

### Committing changes

Use atomic commits per logical change:
```bash
# Stage and commit with descriptive conventional message
git add <files>
git commit -m "feat(scope): short description

- Detail 1
- Detail 2"

# Or use the Makefile shortcut (timestamped commit)
make git-add-commit
make git-push
```

### Syncing all branches from dev

After merging PRs to `dev`, update all topic branches using the Makefile target:
```bash
cd ~/Work/Dotfiles/makefile
make git-sync REPO=Dotfiles
```

Or manually if needed:
```bash
for branch in scripts nix makefile astro-site; do
  git -C ~/Work/Dotfiles/$branch pull --rebase origin dev
  git -C ~/Work/Dotfiles/$branch push
done
```

> **Note:** `minimal-installation` is **excluded** from both the Makefile target and the manual loop. It is a protected branch and must not receive changes from `dev`.

## Agent Responsibilities for This Workflow

When working on this project, AI agents must:

- **Never modify `main` directly** — only via PR from `dev`
- **Never modify `minimal-installation`** — it is a protected branch that provides a lightweight, minimal system install. It must stay lean by design. Users wanting the full system must use `main` instead.
- **Work in the correct worktree** for the changes being made (e.g. `.nix` files → `nix/` worktree)
- **Create atomic commits** — one logical change per commit, with conventional commit message
- **Open detailed PRs** to `dev` with description of what changed and why
- **Sync all branches** after merging to `dev`, resolving conflicts conservatively
- **Use `make git-setup`** when bootstrapping new repos — never raw `git clone`
- **Respect `WORKTREES_HOME`/`BARE_HOME`** — never hardcode paths

## Common Mistakes to Avoid

1. **Mixed Languages**: No Spanish comments
2. **Redundancy**: Don't repeat what the code clearly shows
3. **Inconsistent Formatting**: Match existing separator lengths
4. **Over-commenting**: Focus on complex or non-obvious parts
5. **Under-commenting**: Explain security implications and overrides
6. **Wrong Separator Usage**: Use appropriate separator type for context:
   - `═══════════════` for major sections and individual targets
   - `───────────────` for sub-sections and inline descriptions
   - `=== ===` for minor groupings within larger sections and option groups in .nix files

## Agent Responsibilities

AI agents must:
- Follow this guide for all code modifications
- Update comments when changing functionality
- Maintain visual consistency
- Flag inconsistencies for human review

## Contact

For questions about commenting standards, refer to the main dotfiles documentation or create an issue.