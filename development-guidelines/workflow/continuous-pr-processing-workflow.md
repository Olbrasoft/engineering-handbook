# Continuous PR Processing Workflow

Autonomous workflow for processing GitHub issues and sub-issues using a non-blocking Pull Request pipeline. The agent processes issues continuously without waiting for code reviews.

## Overview

This workflow maximizes throughput by:
- **Never waiting** for code review completion
- **Processing issues in parallel** with PR creation and review
- **Merging PRs asynchronously** when reviews complete

The key principle: **Always have work in progress while previous work is being reviewed.**

## Algorithm

### Phase 1: Analysis & Planning

```
1. Analyze main issue and all sub-issues
2. Understand the complete workflow requirements
3. Divide work into logical parts (1 to X issues per part)
   - Group related issues together
   - Each part should be suitable for one PR
   - Consider dependencies between issues
```

### Phase 2: Pipeline Loop

```
┌─────────────────────────────────────────────────────────────────┐
│                    CONTINUOUS PROCESSING LOOP                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐         │
│  │  Process    │    │  Create     │    │  Continue   │         │
│  │  Part 1     │───▶│  PR1        │───▶│  Immediately│         │
│  │  (Issues)   │    │             │    │  (No Wait)  │         │
│  └─────────────┘    └─────────────┘    └──────┬──────┘         │
│                                               │                 │
│  ┌─────────────┐    ┌─────────────┐    ┌──────▼──────┐         │
│  │  Process    │    │  Create     │    │  Check PR1  │         │
│  │  Part 2     │───▶│  PR2        │───▶│  Review     │         │
│  │  (Issues)   │    │             │    │  Status     │         │
│  └─────────────┘    └─────────────┘    └──────┬──────┘         │
│                                               │                 │
│                     ┌─────────────────────────┼─────────────┐   │
│                     │                         │             │   │
│              ┌──────▼──────┐          ┌───────▼───────┐     │   │
│              │ Review Done │          │ Review Not    │     │   │
│              │             │          │ Done Yet      │     │   │
│              └──────┬──────┘          └───────┬───────┘     │   │
│                     │                         │             │   │
│         ┌───────────┴───────────┐             │             │   │
│         │                       │             │             │   │
│  ┌──────▼──────┐        ┌───────▼───────┐     │             │   │
│  │ Has Comments│        │ No Comments   │     │             │   │
│  │ Fix Issues  │        │ Merge PR1     │     │             │   │
│  │ Then Merge  │        │ Immediately   │     │             │   │
│  └─────────────┘        └───────────────┘     │             │   │
│                                               │             │   │
│                     ┌─────────────────────────┘             │   │
│                     │                                       │   │
│              ┌──────▼──────┐                                │   │
│              │ Continue to │                                │   │
│              │ Part 3...   │◀───────────────────────────────┘   │
│              └─────────────┘                                    │
│                                                                 │
│              (Repeat until all issues processed                 │
│               and all PRs merged)                               │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Phase 3: Detailed Steps

#### Step 1: Process First Part
```bash
# Implement issues for Part 1
# Make code changes
# Run tests
# Create PR1
gh pr create --title "Part 1: [description]" --body "Closes #X, #Y, #Z"
```

#### Step 2: Continue Immediately (DO NOT WAIT)
```bash
# DO NOT wait for PR1 review
# Immediately start Part 2
# Implement issues for Part 2
# Create PR2
gh pr create --title "Part 2: [description]" --body "Closes #A, #B"
```

#### Step 3: Check Previous PR Review Status
```bash
# After creating PR2, check if PR1 review is complete
gh pr view 1 --json reviews,comments

# If review complete with comments:
#   - Fix the issues
#   - Push fixes
#   - Merge PR1 (no need to wait for re-review)
#   - gh pr merge 1 --merge

# If review complete without comments:
#   - Merge PR1 immediately
#   - gh pr merge 1 --merge

# If review NOT complete:
#   - Continue to Part 3 (DO NOT WAIT)
```

#### Step 4: Repeat Until Complete
```
Continue the loop:
1. Process next part → Create PRn
2. Check PRn-2 review status → Fix & Merge if ready
3. Check PRn-1 review status → Fix & Merge if ready
4. Repeat until:
   - All issues are processed
   - All PRs are merged
```

## Key Principles

### Never Wait
| Situation | Action |
|-----------|--------|
| PR created | Continue to next issues immediately |
| Review not complete | Continue working, check later |
| Review complete with comments | Fix issues, merge, continue |
| Review complete, no comments | Merge immediately, continue |

### Code Review Timing
- **Review triggers automatically** when PR is created (GitHub Copilot)
- **Agent does NOT wait** for review to complete
- **Agent checks review status** only between iterations
- **Fixes are applied once** - no re-review after fixes

### Merge Strategy
```
PR1 Created → Work on Part 2
PR2 Created → Check PR1 → Merge PR1 if ready → Work on Part 3
PR3 Created → Check PR2 → Merge PR2 if ready → Work on Part 4
...
All parts done → Merge remaining PRs as reviews complete
```

## Example Workflow

### Scenario: 12 Issues to Process

```
Analysis:
- Issues #1-#4: Database layer (Part 1)
- Issues #5-#7: API layer (Part 2)  
- Issues #8-#10: Service layer (Part 3)
- Issues #11-#12: Integration (Part 4)

Execution:

Time T1: Implement #1-#4 → Create PR1
Time T2: Implement #5-#7 → Create PR2
         Check PR1 review → Not done yet → Continue
Time T3: Implement #8-#10 → Create PR3
         Check PR1 review → Done, 2 comments → Fix → Merge PR1
         Check PR2 review → Done, no comments → Merge PR2
Time T4: Implement #11-#12 → Create PR4
         Check PR3 review → Done, 1 comment → Fix → Merge PR3
Time T5: All issues done
         Check PR4 review → Done → Merge PR4
         
COMPLETE: All issues resolved, all PRs merged
```

## Commands Reference

### Create PR
```bash
gh pr create --title "[Part X]: Description" --body "$(cat <<'EOF'
## Summary
- Implements issues #A, #B, #C
- [Brief description of changes]

Closes #A, #B, #C
EOF
)"
```

### Check PR Review Status
```bash
# View PR details including reviews
gh pr view <PR_NUMBER> --json state,reviews,comments,reviewDecision

# List review comments
gh api repos/{owner}/{repo}/pulls/<PR_NUMBER>/comments
```

### Merge PR
```bash
# Merge after review is complete
gh pr merge <PR_NUMBER> --merge

# Or with squash
gh pr merge <PR_NUMBER> --squash
```

### Fix Review Comments
```bash
# Make changes based on review feedback
# Commit and push
git add .
git commit -m "Address review comments on PR#X"
git push

# Then merge (no re-review required)
gh pr merge <PR_NUMBER> --merge
```

## Anti-Patterns

| Anti-Pattern | Why It's Wrong | Correct Approach |
|--------------|----------------|------------------|
| Waiting for review | Wastes time | Continue immediately |
| Asking for approval | Slows workflow | Process autonomously |
| Single PR for all issues | Too large, hard to review | Split into logical parts |
| Re-requesting review after fixes | Unnecessary delay | Merge after fixing |
| Sequential processing | Low throughput | Pipeline processing |

## Integration with Existing Workflow

This workflow extends:
- **[Git Workflow](git-workflow-workflow.md)** - Branch and commit conventions
- **[Feature Development](feature-development-workflow.md)** - Implementation phases

And integrates with:
- **[Code Review](../code-review/index-code-review.md)** - Automated review processes
- **[Continuous Integration](../dotnet/continuous-integration/index-continuous-integration.md)** - CI checks on PRs

## See Also

- [Git Workflow](git-workflow-workflow.md) - Branch naming, commits
- [GitHub Operations](github-operations-workflow.md) - GitHub CLI commands
- [Feature Development](feature-development-workflow.md) - Implementation phases
