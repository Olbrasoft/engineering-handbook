# Continuous Deployment

Automated publishing and deployment after successful build and tests.

## What is Continuous Deployment?

**Continuous Deployment (CD)** = Automatically **publish** or **deploy** code after tests pass.

**Goal:** Deliver code to **users** (NuGet.org, production server, GitHub Releases).

**Requires CI first** - see [../continuous-integration/](../continuous-integration/)

## Decision Tree

```
What type of project?
│
├─ Class Library
│  └─ Publish to NuGet.org → nuget-publish-continuous-deployment.md
│
├─ Web Service (ASP.NET Core)
│  └─ Deploy to server → web-deploy-continuous-deployment.md
│
├─ Local Application
│  └─ Deploy to /opt/olbrasoft/<app>/ → local-apps-deploy-continuous-deployment.md
│
└─ Desktop Application (GUI)
   └─ Release to GitHub → desktop-release-continuous-deployment.md
```

## Quick Navigation

| Project Type | Deploy Target | File |
|--------------|---------------|------|
| NuGet packages | NuGet.org | [nuget-publish-continuous-deployment.md](nuget-publish-continuous-deployment.md) |
| Web services | Local server | [web-deploy-continuous-deployment.md](web-deploy-continuous-deployment.md) |
| Local apps | `/opt/olbrasoft/<app>/` | [local-apps-deploy-continuous-deployment.md](local-apps-deploy-continuous-deployment.md) |
| Desktop apps | GitHub Releases | [desktop-release-continuous-deployment.md](desktop-release-continuous-deployment.md) |

## CD Pipeline Steps

```
CI Succeeds (build + test pass)
    ↓
Package/Publish
    ↓
Deploy to Target
    ↓
Verify Deployment
    ↓
✅ Deployed → Users can access
```

## Deployment Types

### NuGet Publishing

```bash
dotnet pack -c Release
dotnet nuget push *.nupkg --source https://api.nuget.org/v3/index.json
```

**Trigger:** Push to `main` or tag `v*`

### Web Service Deployment

```bash
dotnet publish -c Release -o /opt/olbrasoft/myapp/app
systemctl --user restart myapp.service
```

**Trigger:** Push to `main` (self-hosted runner)

### Desktop Release

```bash
dotnet publish -r linux-x64 --self-contained
gh release create v1.0.0 MyApp-linux-x64.zip
```

**Trigger:** Tag `v*`

## Files in This Directory

- **[nuget-publish-continuous-deployment.md](nuget-publish-continuous-deployment.md)** - Publish NuGet packages to NuGet.org
- **[web-deploy-continuous-deployment.md](web-deploy-continuous-deployment.md)** - Deploy ASP.NET Core web services
- **[local-apps-deploy-continuous-deployment.md](local-apps-deploy-continuous-deployment.md)** - Deploy local applications
- **[desktop-release-continuous-deployment.md](desktop-release-continuous-deployment.md)** - Create GitHub Releases for desktop apps

## Prerequisites

Before deployment:
- ✅ CI succeeds ([../continuous-integration/](../continuous-integration/))
- ✅ All tests pass
- ✅ Secrets configured (API keys, database connections)

## See Also

- [Continuous Integration](../continuous-integration/) - Build and test before deployment
- [Local Package Testing](../package-management/local-testing-package-management.md) - Test NuGet packages locally before publishing
- [Secrets Management](../secrets-management.md) - How to manage production secrets
