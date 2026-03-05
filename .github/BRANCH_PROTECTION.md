# Branch Protection Guide

## Minimal Installation Branch Protection

The `minimal-installation` branch should be protected to prevent accidental modifications, as it represents a stable snapshot of v1.0.0.

### Manual Setup (GitHub Web UI)

1. Go to **Settings** > **Branches** in your repository
2. Click **Add rule**
3. Configure the following:
   - **Branch name pattern:** `minimal-installation`
   - **Protect matching branches:** ✓
   - **Restrict who can push to matching branches:** ✓
     - Select: Only administrators
   - (Optional) **Require pull request reviews before merging:** ✓
   - (Optional) **Require status checks to pass before merging:** ✓

### Using GitHub CLI (Requires Admin Permissions)

```bash
gh api repos/ravn-ruby-path/Dotfiles/branches/minimal-installation/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"contexts":[]}' \
  --field enforce_admins=true \
  --field required_pull_request_reviews='{"dismissal_restrictions":{},"dismiss_stale_reviews":false,"require_code_owner_reviews":false,"required_approving_review_count":1}' \
  --field restrictions=null
```

### Recommended Settings

- **Restrict pushes:** Only administrators
- **Allow force pushes:** ❌ Disabled
- **Allow deletions:** ❌ Disabled
- **Require pull request reviews:** Optional (recommended if you want extra safety)

### Why Protect This Branch?

- Maintains stable snapshot of v1.0.0
- Prevents accidental modifications
- Ensures users can always access the minimal installation
- Preserves historical reference point

---

**Note:** This file is for documentation purposes. Branch protection must be configured manually through GitHub's web interface or by a repository administrator.
