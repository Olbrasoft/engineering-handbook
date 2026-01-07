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

**Why sub-issues > checkboxes:**
- Trackable separately
- Assignable to different people
- Have their own state (open/closed)
- Visible in project boards

**Naming convention:** "Issue #57 - part of #56"

**Create via API:**
```bash
# Get issue node ID (not number!)
gh api repos/owner/repo/issues/123 --jq '.node_id'

# Link as sub-issue (GraphQL)
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
