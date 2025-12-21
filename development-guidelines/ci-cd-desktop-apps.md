# CI/CD for Desktop Applications

Publishing standalone GUI applications via GitHub Releases.

## When to Use
- Project type: WinForms, WPF, Avalonia, MAUI
- Distribution: GitHub Releases
- Examples: Desktop apps with GUI

## Supported Formats

| Platform | Format | Description |
|----------|--------|-------------|
| Linux | AppImage | Single-file executable, no install |
| Linux | .deb | Debian/Ubuntu package |
| Windows | .exe | Installer (MSI/NSIS) |
| macOS | .app | DMG disk image |
| All | .zip | Portable binaries |

## Build Workflow

```yaml
name: Build
on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - uses: actions/setup-dotnet@v4
      with:
        dotnet-version: 10.0.x
    - run: dotnet restore
    - run: dotnet build -c Release --no-restore
    - run: dotnet test -c Release --no-build
```

## Release Workflow

```yaml
name: Release
on:
  push:
    tags: ['v*']

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - uses: actions/setup-dotnet@v4
    
    - name: Extract version
      id: version
      run: |
        VERSION=${GITHUB_REF#refs/tags/v}
        echo "version=$VERSION" >> $GITHUB_OUTPUT
    
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
    
    - name: Create archives
      run: |
        cd publish/linux-x64 && zip -r ../../MyApp-${{ steps.version.outputs.version }}-linux-x64.zip . && cd ../..
        cd publish/win-x64 && zip -r ../../MyApp-${{ steps.version.outputs.version }}-win-x64.zip . && cd ../..
    
    - name: Create Release
      uses: softprops/action-gh-release@v1
      with:
        files: |
          MyApp-${{ steps.version.outputs.version }}-linux-x64.zip
          MyApp-${{ steps.version.outputs.version }}-win-x64.zip
```

## Versioning

### From Git Tag
```yaml
- name: Extract version
  run: |
    VERSION=${GITHUB_REF#refs/tags/v}  # v1.2.3 → 1.2.3
    echo "version=$VERSION" >> $GITHUB_OUTPUT
```

### In .csproj
```xml
<PropertyGroup>
  <Version>1.0.0</Version>
  <AssemblyVersion>1.0.0.0</AssemblyVersion>
  <FileVersion>1.0.0.0</FileVersion>
</PropertyGroup>
```

## Publish Options

```bash
dotnet publish \
  -c Release \
  -r <runtime-identifier> \
  --self-contained true \
  -p:PublishSingleFile=true \
  -p:IncludeNativeLibrariesForSelfExtract=true \
  -p:PublishTrimmed=true \
  -o ./output
```

**Runtime Identifiers:**
- `linux-x64`, `linux-arm64`
- `win-x64`, `win-arm64`
- `osx-x64`, `osx-arm64`

## Checklist

- [ ] Build workflow for pull requests
- [ ] Release workflow triggered by tag `v*`
- [ ] Multi-platform publish (Linux, Windows, macOS)
- [ ] ZIP archives for distribution
- [ ] Version extracted from Git tag
- [ ] Release notes in GitHub Release

## TODO

- AppImage creation guide
- .deb package creation
- MSI installer for Windows
- Code signing

## Reference

- [.NET Publish Docs](https://learn.microsoft.com/en-us/dotnet/core/deploying/)
- [GitHub Releases](https://docs.github.com/en/repositories/releasing-projects-on-github)
- [AppImage](https://appimage.org/)
