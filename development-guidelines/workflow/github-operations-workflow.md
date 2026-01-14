# GitHub Operations

**Index:** [index-workflow.md](index-workflow.md)

---

## gh CLI Basics

Check auth: `gh auth status`

## Issues

```bash
# List
gh issue list -R owner/repo --limit 10

# View
gh issue view 123 -R owner/repo

# Create
gh issue create -R owner/repo --title "Title" --body "Body"

# Close
gh issue close 123 -R owner/repo
```

## Sub-Issues

> [!CAUTION]
> **STRICT RULE: SUB-ISSUE LINKING VIA API ONLY**
>
> It is **STRICTLY FORBIDDEN** to link sub-issues by pasting text links into the parent issue body.
>
> | ❌ FORBIDDEN | ✅ REQUIRED |
> |--------------|-------------|
> | Adding `#123` to description | Use GraphQL `addSubIssue` mutation |
> | Adding `- [ ] #123` checkbox | Use `gh api graphql` command below |
> | Pasting `https://github.com/.../issues/123` | Use MCP `github_sub_issue_write` tool |
>
> **Why this matters:**
> - Text links create NO database relationship
> - GitHub project boards cannot track text links
> - Automation tools cannot detect text links
> - Sub-issue progress tracking requires formal API linking

**Why sub-issues > checkboxes:**
- Trackable separately
- Assignable to different people
- Have their own state (open/closed)
- Visible in project boards

**Naming convention:** "Issue #57 - part of #56"

**Create via API (MANDATORY METHOD):**
```bash
# Step 1: Get issue node IDs (not numbers!)
gh api repos/owner/repo/issues/123 --jq '.node_id'  # Parent
gh api repos/owner/repo/issues/456 --jq '.node_id'  # Child

# Step 2: Link as sub-issue (GraphQL) - THIS IS REQUIRED!
gh api graphql -f query='
mutation {
  addSubIssue(input: {
    issueId: "PARENT_NODE_ID",
    subIssueId: "CHILD_NODE_ID"
  }) {
    issue { id }
  }
}'
```

**Using MCP Server (alternative):**
```
github_sub_issue_write:
  - method: "add"
  - issue_number: 123 (parent)
  - sub_issue_id: 3725925667 (child numeric ID from API)
```

## PRs

```bash
# List
gh pr list -R owner/repo --limit 10

# View
gh pr view 123 -R owner/repo

# Create
gh pr create -R owner/repo --title "Title" --body "Body"
```

## Search

```bash
# Search issues
gh search issues "query" --repo owner/repo --limit 10

# Search PRs
gh search prs "query" --repo owner/repo --limit 10
```

## GitHub API

```bash
# Any REST endpoint
gh api repos/owner/repo/issues

# With jq filter
gh api repos/owner/repo/issues --jq '.[].title'

# POST request
gh api repos/owner/repo/issues --method POST -f title="New issue" -f body="Description"
```

## Webhooks

```bash
gh api repos/owner/repo/hooks --method POST \
  -f name='web' \
  -f config[url]='https://example.com/webhook' \
  -f events[]='issues' \
  -f events[]='pull_request'
```

---

**Remember:** Always use `-R owner/repo` to specify repository.
