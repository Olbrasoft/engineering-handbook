## Known Issues

### Translation System Issues

**Issue #301**: [Translation System Analysis](https://github.com/Olbrasoft/GitHub.Issues/issues/301)
- Problem: Bing was primary provider, rate-limited (HTTP 429)
- Status: ✅ Fixed (provider order updated to DeepL → Azure → Google → Bing)

**Issue #302**: [Translation Monitoring System](https://github.com/Olbrasoft/GitHub.Issues/issues/302)
- Problem: No monitoring of translation attempts/failures
- Proposed: Database logging table, alert system for quotas
- Status: ⏳ Designed, not yet implemented

**Issue #303**: [API Usage Tracking](https://github.com/Olbrasoft/GitHub.Issues/issues/303)
- Problem: Cannot track remaining DeepL/Azure quotas
- Solution: DeepL native API (`/v2/usage`), Azure client-side tracking
- Status: ⏳ Researched, not yet implemented

### Security Issues

**Issue #304**: [Prevent Manual Production Edits](https://github.com/Olbrasoft/GitHub.Issues/issues/304)
- Problem: Regular user can manually edit production files, bypassing CI/CD
- Solution: Dedicated `gh-deploy` user with restricted permissions
- Status: ⏳ Designed, not yet implemented

### Recent Errors

1. **Exposed API Keys in GitHub Issues** (2025-12-29)
   - Error: Wrote Azure/DeepL API keys to GitHub issues #301, #303
   - Detection: GitHub security alert
   - Fix: Deleted all comments with keys, replaced with safe versions
   - Action: User recommended rotating all exposed keys

2. **Manual Production Config Edit** (2025-12-29)
   - Error: Manually edited `/opt/olbrasoft/github-issues/config/appsettings.json`
   - Problem: Bypassed Git workflow, changes would be lost on next deploy
   - Fix: Updated source code, committed, pushed → GitHub Actions deployed
   - Lesson: **NEVER manually edit production config** - always use Git workflow

---

