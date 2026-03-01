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