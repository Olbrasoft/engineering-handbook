# CI/CD Pipeline Setup for NuGet Package Publishing

## Overview

This document describes how to set up automated CI/CD pipelines for building, testing, and publishing .NET NuGet packages to NuGet.org using GitHub Actions.

---

## 🎯 Kdy kontrolovat CI/CD nastavení

**KRITICKÉ - PŘI KAŽDÉM PROJEKTU:**

Při zahájení práce na **jakémkoli .NET projektu**, který publikuje NuGet balíčky, **VŽDY zkontroluj**, zda existuje správné CI/CD nastavení:

### Kontrolní seznam:

- [ ] Existuje `.github/workflows/build.yml`?
- [ ] Existuje `.github/workflows/publish-nuget.yml`?
- [ ] Je nakonfigurovaný GitHub Secret `NUGET_API_KEY`?
- [ ] Obsahují workflows všechny podporované .NET verze?
- [ ] Jsou v README.md CI/CD status badges?

**Pokud COKOLIV chybí → implementuj to podle tohoto průvodce!**

---

## 📦 Jak funguje publikace balíčků

### Repository-specifická konfigurace

**DŮLEŽITÉ:** CI/CD pipeline je **specifická pro každý GitHub repository**, NENÍ globální.

Pro **každý projekt** musíš:
1. Vytvořit workflow soubory (`.github/workflows/*.yml`)
2. Nastavit GitHub Secret s NuGet API klíčem
3. Nakonfigurovat metadata v `.csproj` souborech

### Automatická detekce balíčků

Pipeline pomocí `dotnet pack` **automaticky najde VŠECHNY** balíčky v solution:

```bash
dotnet pack --configuration Release --no-build --output ./artifacts
```

Tímto příkazem se vytvoří `.nupkg` soubory pro:
- Všechny projekty, které mají `<IsPackable>true</IsPackable>` (nebo to nemají zakázané)
- Všechny projekty s nastavenými NuGet metadaty (`<PackageId>`, `<Version>`, atd.)

**Příklad:** V projektu Mediation se publikují **2 balíčky najednou**:
- `Olbrasoft.Mediation.X.X.X.nupkg`
- `Olbrasoft.Mediation.Abstractions.X.X.X.nupkg`

### Kdy se publikuje

Publikace na NuGet.org se spustí **pouze když**:

1. ✅ Všechny testy prošly (`dotnet test` exit code 0)
2. ✅ **A** je to push na `main` branch **NEBO** push tagu `v*` (např. `v10.0.0`)

```yaml
if: success() && (github.ref == 'refs/heads/main' || startsWith(github.ref, 'refs/tags/v'))
```

---

## 🔧 Implementace CI/CD v novém projektu

### Krok 1: NuGet API klíč

**Umístění klíče:**
```
~/Dokumenty/Keys/nuget-key.txt
```

**Přidání do GitHub Secrets:**

1. Přečti klíč ze souboru:
   ```bash
   cat ~/Dokumenty/Keys/nuget-key.txt
   ```

2. Přidej do GitHub repository:
   - Jdi na: `Settings` → `Secrets and variables` → `Actions`
   - Klikni: `New repository secret`
   - Name: `NUGET_API_KEY`
   - Value: *[obsah souboru nuget-key.txt]*
   - Ulož

**⚠️ POZOR:** Stejný NuGet API klíč můžeš použít pro všechny Olbrasoft projekty.

---

### Krok 2: Build Workflow

Vytvoř soubor `.github/workflows/build.yml`:

```yaml
name: Build

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup .NET
      uses: actions/setup-dotnet@v4
      with:
        dotnet-version: |
          6.0.x
          7.0.x
          8.0.x
          9.0.x
          10.0.x
    
    - name: Restore
      run: dotnet restore
    
    - name: Build
      run: dotnet build --configuration Release --no-restore
    
    - name: Test
      run: dotnet test --configuration Release --no-build --verbosity normal
```

**Co dělá:**
- Spouští se při pushu na `main`/`develop` nebo pull requestech
- Nainstaluje všechny podporované .NET SDK verze
- Restore → Build → Test
- **Nepublikuje** na NuGet

---

### Krok 3: Publish Workflow

Vytvoř soubor `.github/workflows/publish-nuget.yml`:

```yaml
name: Build, Test & Publish NuGet Package

on:
  push:
    branches: [ main ]
    tags: [ 'v*' ]
  pull_request:
    branches: [ main ]
  workflow_dispatch:

permissions:
  contents: read
  checks: write
  pull-requests: write

env:
  DOTNET_SKIP_FIRST_TIME_EXPERIENCE: true
  DOTNET_CLI_TELEMETRY_OPTOUT: true

jobs:
  build-test-publish:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      with:
        fetch-depth: 0  # Full history for versioning
    
    - name: Setup .NET SDK
      uses: actions/setup-dotnet@v4
      with:
        dotnet-version: |
          6.0.x
          7.0.x
          8.0.x
          9.0.x
          10.0.x

    - name: Display .NET info
      run: dotnet --info
    
    - name: Restore dependencies
      run: dotnet restore
    
    - name: Build solution
      run: dotnet build --configuration Release --no-restore
    
    - name: Run tests
      run: dotnet test --configuration Release --no-build --verbosity normal
    
    - name: Pack NuGet packages
      if: success()
      run: dotnet pack --configuration Release --no-build --output ./artifacts
    
    - name: List artifacts
      if: success()
      run: ls -lh ./artifacts/
    
    - name: Publish to NuGet.org
      if: success() && (github.ref == 'refs/heads/main' || startsWith(github.ref, 'refs/tags/v'))
      run: |
        dotnet nuget push ./artifacts/*.nupkg \
          --source https://api.nuget.org/v3/index.json \
          --api-key ${{ secrets.NUGET_API_KEY }} \
          --skip-duplicate
    
    - name: Upload artifacts
      if: success()
      uses: actions/upload-artifact@v4
      with:
        name: nuget-packages
        path: ./artifacts/*.nupkg
        retention-days: 30
```

**Co dělá:**
- Spouští se při pushu na `main`, tagech `v*`, pull requestech
- Restore → Build → Test → Pack
- **Publikuje na NuGet.org** pouze při pushu na `main` nebo tag `v*`
- Používá `--skip-duplicate` - nepřepíše existující verzi
- Ukládá artefakty (.nupkg) pro 30 dní

**Klíčové parametry:**
- `permissions:` - Povolení pro GitHub Actions
- `NUGET_API_KEY` - GitHub Secret s API klíčem
- `--skip-duplicate` - Zabránění chybě při již existující verzi

---

### Krok 4: NuGet metadata v .csproj

Každý projekt, který chceš publikovat, musí mít metadata:

```xml
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <TargetFrameworks>netstandard2.1;net6.0;net7.0;net8.0;net9.0;net10.0</TargetFrameworks>
    
    <!-- NuGet Package Metadata -->
    <PackageId>Olbrasoft.YourProject</PackageId>
    <Version>1.0.0</Version>
    <Authors>Olbrasoft</Authors>
    <Company>Olbrasoft</Company>
    <Product>Olbrasoft YourProject</Product>
    <Description>Your package description</Description>
    <Copyright>© Olbrasoft 2025</Copyright>
    
    <!-- NuGet Publishing -->
    <PackageLicenseExpression>MIT</PackageLicenseExpression>
    <PackageProjectUrl>https://github.com/Olbrasoft/YourProject</PackageProjectUrl>
    <PackageIcon>icon.png</PackageIcon>
    <PackageReadmeFile>README.md</PackageReadmeFile>
    <PackageTags>Tag1;Tag2;NET10</PackageTags>
    <PackageReleaseNotes>Version 1.0.0: Initial release</PackageReleaseNotes>
    
    <!-- Optional: Disable packaging if this is a test/internal project -->
    <!-- <IsPackable>false</IsPackable> -->
  </PropertyGroup>

  <ItemGroup>
    <None Include="..\..\icon.png" Pack="True" PackagePath="\" />
    <None Include="..\..\README.md" Pack="True" PackagePath="\" />
  </ItemGroup>

</Project>
```

**Důležité vlastnosti:**
- `<Version>` - Verzování balíčku (semantic versioning)
- `<PackageId>` - Jedinečný identifikátor na NuGet.org
- `<IsPackable>false</IsPackable>` - Zakáže publikaci (pro testovací projekty)

---

### Krok 5: README badges

Přidej status badges do `README.md`:

```markdown
[![Build](https://github.com/Olbrasoft/YourProject/actions/workflows/build.yml/badge.svg)](https://github.com/Olbrasoft/YourProject/actions/workflows/build.yml)
[![Publish NuGet](https://github.com/Olbrasoft/YourProject/actions/workflows/publish-nuget.yml/badge.svg)](https://github.com/Olbrasoft/YourProject/actions/workflows/publish-nuget.yml)
[![NuGet](https://img.shields.io/nuget/v/Olbrasoft.YourProject.svg)](https://www.nuget.org/packages/Olbrasoft.YourProject/)
```

---

## 🔄 Workflow při vývoji

### Běžný vývoj (feature branch)

```bash
# Vytvoř branch
git checkout -b feature/new-feature

# Vyvíjej + testy
# ...

# Commit a push
git add .
git commit -m "feat: Add new feature"
git push origin feature/new-feature
```

**Výsledek:** Spustí se pouze **Build workflow** (žádná publikace).

### Release (merge do main)

```bash
# Merge do main
git checkout main
git merge feature/new-feature
git push origin main
```

**Výsledek:** 
1. Spustí se **Build workflow**
2. Spustí se **Publish workflow**
3. Pokud testy projdou → **Publikace na NuGet.org**

### Tagged release

```bash
# Vytvoř tag
git tag v1.0.0
git push origin v1.0.0
```

**Výsledek:** Stejné jako merge do main + tag v Git historii.

---

## 🚨 Běžné problémy

### 1. Workflow nemá oprávnění

**Chyba:**
```
Resource not accessible by integration: 403
```

**Řešení:**
Přidej `permissions:` blok do workflow:

```yaml
permissions:
  contents: read
  checks: write
  pull-requests: write
```

### 2. Publikace selže s "Package already exists"

**Chyba:**
```
Response status code does not indicate success: 409 (Conflict - The feed already contains 'Package' version 'X.X.X'.)
```

**Řešení:**
Zvyš verzi v `.csproj` souboru:

```xml
<Version>1.0.1</Version>  <!-- Změna z 1.0.0 -->
```

Nebo použij `--skip-duplicate` flag (už je ve workflow).

### 3. NuGet API klíč není nastaven

**Chyba:**
```
error: Unable to load the service index for source https://api.nuget.org/v3/index.json
```

**Řešení:**
Zkontroluj, že GitHub Secret `NUGET_API_KEY` existuje a je správně nakonfigurovaný.

### 4. Testy selhávají v CI, lokálně fungují

**Možné příčiny:**
- Rozdílné .NET verze
- Chybějící závislosti
- Časově závislé testy

**Řešení:**
Spusť testy lokálně se všemi .NET verzemi:

```bash
dotnet test --framework net6.0
dotnet test --framework net8.0
dotnet test --framework net10.0
```

---

## 📚 Reference

### Oficiální odkazy

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [NuGet CLI Reference](https://docs.microsoft.com/en-us/nuget/reference/cli-reference/cli-ref-push)
- [.NET Multi-targeting](https://docs.microsoft.com/en-us/dotnet/standard/frameworks)

### Příklady v Olbrasoft projektech

- [Mediation CI/CD](https://github.com/Olbrasoft/Mediation/tree/main/.github/workflows)
  - `build.yml` - Build workflow
  - `publish-nuget.yml` - Publish workflow
  - Publikuje 2 balíčky: `Olbrasoft.Mediation` + `Olbrasoft.Mediation.Abstractions`

---

## ✅ Checklist pro nový projekt

Před začátkem vývoje zkontroluj:

- [ ] `.github/workflows/build.yml` existuje
- [ ] `.github/workflows/publish-nuget.yml` existuje
- [ ] GitHub Secret `NUGET_API_KEY` je nastaven (Settings → Secrets)
- [ ] `.csproj` obsahuje NuGet metadata (`PackageId`, `Version`, `Description`, ...)
- [ ] `README.md` obsahuje CI/CD status badges
- [ ] Workflows obsahují všechny podporované .NET verze (6, 7, 8, 9, 10)
- [ ] `permissions:` blok je v publish workflow
- [ ] Lokální testy prochází: `dotnet test`

**Pokud cokoliv chybí → implementuj podle tohoto průvodce!**
