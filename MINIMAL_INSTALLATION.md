# 📦 Minimal Installation Branch

This branch (`minimal-installation`) provides a **stable, minimal, and fully functional** version of the dotfiles configuration, frozen at **v1.0.0**.

## 🎯 Purpose

This branch is designed for users who want:
- ✅ A **stable, tested** configuration that won't change
- ✅ **Minimal setup** with essential features only
- ✅ **Git configuration** (SSH, GPG, GitHub)
- ✅ **Cloudflare DNS** for speed and privacy
- ✅ **Core NixOS/Home Manager** setup
- ✅ **Basic Makefile** commands for system management

## 📋 What's Included

### Core Features
- **NixOS/Home Manager** declarative configuration
- **Git setup script** (`git-setup.sh`) for complete Git configuration
- **Cloudflare DNS** override with DNS over TLS
- **Makefile** with 70+ commands for system management
- **Pre-commit hooks** for code quality
- **VS Code** configuration for Nix development
- **Basic documentation** structure

### What's NOT Included (in full branch)
- Advanced features added after v1.0.0
- Experimental configurations
- Additional modules or packages
- Extended documentation site

## 🚀 Installation

```bash
# Clone the minimal installation branch
git clone -b minimal-installation https://github.com/ravn-ruby-path/Dotfiles.git
cd Dotfiles

# Configure Git (recommended)
./git-setup.sh

# Apply configuration
sudo nixos-rebuild switch --flake .#hydenix
```

## 🔄 Upgrading to Full Installation

If you want the latest features and updates:

```bash
git remote set-branches --add origin main
git fetch origin
git checkout main
```

## 📊 Version Information

- **Version:** v1.0.0
- **Commit:** `5c4b572`
- **Release Date:** March 4, 2026
- **Status:** Stable, frozen

## 🔗 Related

- **Full Installation:** See `main` branch for latest features
- **Release Notes:** [v1.0.0 Release](https://github.com/ravn-ruby-path/Dotfiles/releases/tag/v1.0.0)
- **Documentation:** [25ASAB015.github.io/nix-dotfiles](https://25ASAB015.github.io/nix-dotfiles)

---

**Note:** This branch is maintained as a stable snapshot. It will not receive updates unless critical security fixes are needed.
