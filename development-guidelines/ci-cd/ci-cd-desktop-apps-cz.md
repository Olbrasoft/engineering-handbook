# CI/CD pro desktopové aplikace

> **Typ projektu:** GUI aplikace (WinForms, WPF, Avalonia, MAUI)
> 
> **Distribuce:** GitHub Releases, .deb balíčky, AppImage
> 
> **Jiný typ projektu?** Viz [ci-cd-overview-cz.md](ci-cd-overview-cz.md)

---

## Overview

Desktopové aplikace se distribuují jako binárky, které si uživatelé stahují a spouští lokálně.

---

## Podporované formáty

| Platforma | Formát | Popis |
|-----------|--------|-------|
| **Linux** | AppImage | Single-file executable, no installation needed |
| **Linux** | .deb balíček | Debian/Ubuntu package manager |
| **Windows** | .exe installer | MSI/NSIS installer |
| **macOS** | .app bundle | DMG disk image |
| **Cross-platform** | .zip archive | Portable binaries |

---

## Workflow Patterns

### 1. Build Workflow (při každém pushu)

```yaml
name: Build

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup .NET
      uses: actions/setup-dotnet@v4
      with:
        dotnet-version: 10.0.x
    
    - name: Restore
      run: dotnet restore
    
    - name: Build
      run: dotnet build --configuration Release --no-restore
    
    - name: Test
      run: dotnet test --configuration Release --no-build --verbosity normal
```

**Spouští se:** Každý push/PR  
**Účel:** Ověření že kód funguje

---

### 2. Release Workflow (při vytvoření tagu)

```yaml
name: Release

on:
  push:
    tags:
      - 'v*'  # Trigger on v1.0.0, v1.2.3, etc.

jobs:
  release:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup .NET
      uses: actions/setup-dotnet@v4
      with:
        dotnet-version: 10.0.x
    
    - name: Extract version from tag
      id: version
      run: |
        VERSION=${GITHUB_REF#refs/tags/v}
        echo "version=$VERSION" >> $GITHUB_OUTPUT
        echo "Building version: $VERSION"
    
    - name: Publish Linux x64
      run: |
        dotnet publish src/MyApp/MyApp.csproj \
          -c Release \
          -r linux-x64 \
          --self-contained true \
          -p:PublishSingleFile=true \
          -p:Version=${{ steps.version.outputs.version }} \
          -o ./publish/linux-x64
    
    - name: Publish Windows x64
      run: |
        dotnet publish src/MyApp/MyApp.csproj \
          -c Release \
          -r win-x64 \
          --self-contained true \
          -p:PublishSingleFile=true \
          -p:Version=${{ steps.version.outputs.version }} \
          -o ./publish/win-x64
    
    - name: Create ZIP archives
      run: |
        cd ./publish/linux-x64 && zip -r ../../MyApp-${{ steps.version.outputs.version }}-linux-x64.zip . && cd ../..
        cd ./publish/win-x64 && zip -r ../../MyApp-${{ steps.version.outputs.version }}-win-x64.zip . && cd ../..
    
    - name: Create GitHub Release
      uses: softprops/action-gh-release@v1
      with:
        files: |
          MyApp-${{ steps.version.outputs.version }}-linux-x64.zip
          MyApp-${{ steps.version.outputs.version }}-win-x64.zip
        body: |
          ## MyApp ${{ steps.version.outputs.version }}
          
          ### Downloads
          - **Linux:** MyApp-${{ steps.version.outputs.version }}-linux-x64.zip
          - **Windows:** MyApp-${{ steps.version.outputs.version }}-win-x64.zip
          
          ### Installation
          
          **Linux:**
          ```bash
          unzip MyApp-${{ steps.version.outputs.version }}-linux-x64.zip
          chmod +x MyApp
          ./MyApp
          ```
          
          **Windows:**
          ```cmd
          unzip MyApp-${{ steps.version.outputs.version }}-win-x64.zip
          MyApp.exe
          ```
```

**Spouští se:** Git tag `v*`  
**Účel:** Vytvoření GitHub Release s binárkami

---

## Verzování

### Automatické z Git tagu

```yaml
- name: Extract version from tag
  id: version
  run: |
    VERSION=${GITHUB_REF#refs/tags/v}  # v1.2.3 → 1.2.3
    echo "version=$VERSION" >> $GITHUB_OUTPUT

- name: Use version
  run: dotnet publish -p:Version=${{ steps.version.outputs.version }}
```

### Manuální v .csproj

```xml
<PropertyGroup>
  <Version>1.0.0</Version>
  <AssemblyVersion>1.0.0.0</AssemblyVersion>
  <FileVersion>1.0.0.0</FileVersion>
  <InformationalVersion>1.0.0</InformationalVersion>
</PropertyGroup>
```

---

## AppImage (Linux)

**TODO:** Přidat návod na vytvoření AppImage pomocí `appimagetool`

**Reference:**
- https://appimage.org/
- https://docs.appimage.org/packaging-guide/index.html

---

## .deb Balíček (Debian/Ubuntu)

**TODO:** Přidat návod na vytvoření .deb balíčku

**Reference:**
- https://www.debian.org/doc/manuals/maint-guide/
- https://learn.microsoft.com/en-us/dotnet/core/deploying/deploy-with-cli#self-contained-deployment

---

## Checklist

- [ ] Build workflow (`build.yml`)
- [ ] Release workflow (`release.yml`)
- [ ] Multi-platform publish (Linux, Windows, macOS)
- [ ] ZIP archivy pro GitHub Releases
- [ ] Verzování z Git tagu
- [ ] Release notes v GitHub Release
- [ ] (Optional) AppImage pro Linux
- [ ] (Optional) .deb balíček
- [ ] (Optional) MSI installer pro Windows

---

## Reference

- [.NET Publish Documentation](https://learn.microsoft.com/en-us/dotnet/core/deploying/)
- [GitHub Releases](https://docs.github.com/en/repositories/releasing-projects-on-github/managing-releases-in-a-repository)
- [AppImage](https://appimage.org/)
- [Debian Packaging](https://www.debian.org/doc/manuals/maint-guide/)
