# Project Setup

How to set up new .NET projects: repository structure, project organization, and initial configuration.

## Overview

This section covers everything needed to start a new .NET project:

- **Repository Setup** - Creating GitHub repo, cloning, initial configuration
- **Project Structure** - Organizing code, folders, naming conventions
- **Project Config** - CLAUDE.md template for AI assistant configuration

## Quick Start

### Create New Project

1. **Create GitHub Repository**
   ```bash
   gh repo create my-project --public --clone
   cd my-project
   ```

2. **Initialize .NET Project**
   ```bash
   dotnet new sln -n MyProject
   mkdir src tests
   dotnet new classlib -n MyProject.Core -o src/MyProject.Core
   dotnet sln add src/MyProject.Core
   ```

3. **Set Up Project Structure**
   - See: [Project Structure](../dotnet/project-structure-dotnet.md) for folder organization

4. **Initial Commit**
   ```bash
   git add .
   git commit -m "Initial project setup"
   git push
   ```

See: [Repository Setup](repository-setup-project-setup.md) for complete guide.

## File Index

- **[repository-setup-project-setup.md](repository-setup-project-setup.md)** - GitHub repository creation, cloning, initial setup
- **[project-config-project-setup.md](project-config-project-setup.md)** - CLAUDE.md template for project-specific AI assistant configuration

**See also:** [.NET Project Structure](../dotnet/project-structure-dotnet.md) - Folder organization, naming conventions, project layout

**See also:** [.NET Layered Naming](../dotnet/layered-naming-dotnet.md) - Project naming for multi-layered applications (Blog example)

## Common Scenarios

### Starting New Library

```bash
# 1. Create repo
gh repo create MyLibrary --public --clone
cd MyLibrary

# 2. Create solution and projects
dotnet new sln -n MyLibrary
mkdir src tests

# 3. Create library project
dotnet new classlib -n MyLibrary.Core -o src/MyLibrary.Core
dotnet sln add src/MyLibrary.Core

# 4. Create test project
dotnet new xunit -n MyLibrary.Core.Tests -o tests/MyLibrary.Core.Tests
dotnet sln add tests/MyLibrary.Core.Tests
dotnet add tests/MyLibrary.Core.Tests reference src/MyLibrary.Core

# 5. Initial commit
git add .
git commit -m "Initial project structure"
git push
```

### Starting New Web Service

```bash
# 1. Create repo
gh repo create MyService --public --clone
cd MyService

# 2. Create solution
dotnet new sln -n MyService
mkdir src tests

# 3. Create web API project
dotnet new webapi -n MyService.Api -o src/MyService.Api
dotnet sln add src/MyService.Api

# 4. Create core library
dotnet new classlib -n MyService.Core -o src/MyService.Core
dotnet sln add src/MyService.Core
dotnet add src/MyService.Api reference src/MyService.Core

# 5. Create test projects
dotnet new xunit -n MyService.Core.Tests -o tests/MyService.Core.Tests
dotnet sln add tests/MyService.Core.Tests
dotnet add tests/MyService.Core.Tests reference src/MyService.Core

# 6. Initial commit
git add .
git commit -m "Initial web service structure"
git push
```

## Best Practices

### Repository Setup

✅ **DO:**
- Use descriptive repository names
- Initialize with README
- Add .gitignore for .NET
- Set up GitHub Actions early
- Use meaningful initial commit messages

❌ **DON'T:**
- Commit bin/ or obj/ folders
- Include IDE-specific files
- Commit secrets or API keys

### Project Structure

✅ **DO:**
- Separate `src/` and `tests/` directories
- One test project per source project
- Use consistent naming (`{Project}.{Layer}`)
- Group related projects in subdirectories

❌ **DON'T:**
- Mix source and test files
- Create monolithic single projects
- Use inconsistent naming
- Nest projects too deeply

## Integration with CI/CD

After setting up project:

1. **Set up Continuous Integration**
   - See: [Build CI](../dotnet/continuous-integration/build-continuous-integration.md)
   - See: [Test CI](../dotnet/continuous-integration/test-continuous-integration.md)

2. **Set up Continuous Deployment**
   - See: [Continuous Deployment](../dotnet/continuous-deployment/index-continuous-deployment.md)

## Next Steps

- **[Repository Setup →](repository-setup-project-setup.md)** - Create GitHub repo and clone
- **[Project Structure →](../dotnet/project-structure-dotnet.md)** - Organize code and folders

## See Also

- [Workflow Guide](../workflow/index-workflow.md) - Git workflow and issues
- [Testing Guide](../dotnet/testing/index-testing.md) - Set up tests
- [Package Management](../dotnet/package-management/index-package-management.md) - NuGet packages
