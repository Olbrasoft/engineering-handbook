# Návrh rozdělení deployment dokumentace

## Problém

Aktuálně máme:
- `ci-cd-pipeline-setup-cz.md` (434 řádků) - **POUZE NuGet balíčky**
- `deployment-secrets-guide.md` (423 řádků) - **POUZE webové aplikace/služby na lokálním serveru**
- `github-repository-setup-cz.md` (390 řádků) - Obecné nastavení GitHub repozitáře

**Chybí jasné rozdělení podle TYPU PROJEKTU!**

---

## Analýza existujících projektů

### 1. NuGet balíčky (TextToSpeech)
- **Repozitář:** https://github.com/Olbrasoft/TextToSpeech
- **Deployment:** Publikace na NuGet.org pomocí GitHub Actions
- **Trigger:** Push na `main` branch nebo tag `v*`
- **Workflow:** Build → Test → Pack → **Publish na NuGet.org**
- **Secrets:** `NUGET_API_KEY` v GitHub Secrets
- **Žádný lokální deployment!** Balíčky se instalují pomocí `dotnet add package`

**Workflow soubor:**
```yaml
name: Build & Publish NuGet Packages
on:
  push:
    branches: [ master, main ]
  workflow_dispatch:

jobs:
  build-publish:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
    
    - name: Setup .NET SDK
      uses: actions/setup-dotnet@v4
      with:
        dotnet-version: 10.0.x
    
    - name: Build
      run: dotnet build --configuration Release
    
    - name: Test
      run: dotnet test --configuration Release
    
    - name: Collect packages
      run: |
        mkdir -p ./artifacts
        find . -name "*.nupkg" -path "*/bin/Release/*" -exec cp {} ./artifacts/ \;
    
    - name: Publish to NuGet.org
      run: |
        dotnet nuget push ./artifacts/*.nupkg \
          --source https://api.nuget.org/v3/index.json \
          --api-key ${{ secrets.NUGET_API_KEY }} \
          --skip-duplicate
```

**Klíčové vlastnosti:**
- ✅ Automatická detekce VŠECH `.nupkg` v solution
- ✅ Verzování přes `<Version>` v `.csproj`
- ✅ `--skip-duplicate` flag (nepřepisuje existující verze)
- ✅ Artifacts storage (30 dní)
- ❌ ŽÁDNÝ lokální deployment
- ❌ ŽÁDNÉ secrets v systemd/startup scriptech

### 2. Webové aplikace/služby (VirtualAssistant)
- **Repozitář:** https://github.com/Olbrasoft/VirtualAssistant
- **Deployment:** Lokální server `/opt/olbrasoft/virtual-assistant/`
- **Trigger:** Manuální `./deploy/deploy.sh` nebo GitHub Actions self-hosted runner
- **Workflow:** Build → Test → Publish → **Restart systemd service**
- **Secrets:** Environment variables v systemd EnvironmentFile
- **Lokální běh:** systemd user service, port 5055

**Deploy script:**
```bash
#!/usr/bin/env bash
set -e

BASE_DIR="/opt/olbrasoft/virtual-assistant"
dotnet test || exit 1
dotnet publish src/VirtualAssistant.Service/VirtualAssistant.Service.csproj \
  -c Release -o "$BASE_DIR/app" --no-self-contained

systemctl --user restart virtual-assistant.service
```

**Klíčové vlastnosti:**
- ✅ Deploy na lokální server
- ✅ Secrets v EnvironmentFile
- ✅ systemd service management
- ✅ Health checks, logs
- ❌ NENÍ na NuGet.org
- ❌ NENÍ stažitelný jako balíček

### 3. Desktopové aplikace (hypoteticky)
- **Deployment:** GitHub Releases s binárkami
- **Workflow:** Build → Test → Package → **Create Release**
- **Distribuce:** .deb balíčky, AppImage, nebo zip archivy

---

## Navrhované rozdělení dokumentace

### Struktura souborů

```
development-guidelines/
├── github-repository-setup-cz.md           # EXISTUJE - obecné nastavení
├── ci-cd-pipeline-setup-cz.md              # EXISTUJE - RENAME → ci-cd-nuget-packages-cz.md
├── deployment-secrets-guide.md             # EXISTUJE - RENAME → ci-cd-web-services-cz.md
├── ci-cd-desktop-apps-cz.md                # NOVÝ - desktopové aplikace
└── ci-cd-overview-cz.md                    # NOVÝ - rozcestník "Jaký typ projektu mám?"
```

### Obsah nových/upravených souborů

#### 1. `ci-cd-overview-cz.md` (NOVÝ) - Rozcestník

```markdown
# CI/CD Overview - Jaký typ projektu mám?

Tento průvodce ti pomůže vybrat správnou CI/CD strategii podle typu projektu.

## 🎯 Rychlé rozhodování

| Typ projektu | Deployment | Dokumentace |
|--------------|------------|-------------|
| **NuGet balíčky** | Publikace na NuGet.org | [ci-cd-nuget-packages-cz.md](ci-cd-nuget-packages-cz.md) |
| **Webové služby/API** | Lokální server (systemd) | [ci-cd-web-services-cz.md](ci-cd-web-services-cz.md) |
| **Desktopové aplikace** | GitHub Releases | [ci-cd-desktop-apps-cz.md](ci-cd-desktop-apps-cz.md) |

## Jak poznat typ projektu?

### NuGet balíčky
- **Účel:** Knihovna, kterou jiní vývojáři použijí ve svých projektech
- **Příklady:** TextToSpeech, Mediation, SystemTray
- **Poznávací znaky:**
  - Obsahuje `<PackageId>` v `.csproj`
  - Má `README.md` s "Installation: `dotnet add package ...`"
  - NENÍ to samostatně spustitelná aplikace
- **Distribuce:** NuGet.org
- **Použití:** `dotnet add package Olbrasoft.TextToSpeech.Core`

### Webové služby/API
- **Účel:** Služba běžící na serveru, přístupná přes HTTP/WebSocket
- **Příklady:** VirtualAssistant, GitHub.Issues, Push-To-Talk API
- **Poznávací znaky:**
  - Obsahuje ASP.NET Core (`Microsoft.AspNetCore.App`)
  - Má systemd service soubor
  - Běží jako long-running process (daemon)
- **Distribuce:** Deployment na `/opt/olbrasoft/<app>/`
- **Použití:** HTTP API na `http://localhost:<port>`

### Desktopové aplikace
- **Účel:** Aplikace, kterou si uživatelé instalují a spouští lokálně
- **Příklady:** WinForms, WPF, Avalonia, MAUI aplikace
- **Poznávací znaky:**
  - Obsahuje GUI framework
  - Má entry point (`Main()`) pro standalone spuštění
  - Targetuje `net10.0` (ne `netstandard2.1`)
- **Distribuce:** GitHub Releases, .deb balíčky, AppImage
- **Použití:** Uživatel stáhne a spustí `.exe` nebo `.AppImage`

## Lze mít více typů v jednom repozitáři?

**ANO!** Příklad: TextToSpeech

**Struktura:**
```
TextToSpeech/
├── src/                          # NuGet balíčky (PUBLIKUJE SE)
│   ├── TextToSpeech.Core/
│   ├── TextToSpeech.Providers/
│   └── TextToSpeech.Orchestration/
└── examples/                     # Demo aplikace (NEPUBLIKUJE SE)
    └── TextToSpeech.Demo/        # Console app pro testování
```

**CI/CD strategie:**
- `src/*` → Publikuje se na NuGet.org
- `examples/*` → Pouze build & test, NEPUBLIKUJE se
- Workflow: `dotnet pack` najde POUZE projekty v `src/` s `<IsPackable>true</IsPackable>`

## Kombinované workflows

### Build (společný pro všechny typy)
```yaml
name: Build
on: [push, pull_request]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-dotnet@v4
      - run: dotnet restore
      - run: dotnet build --configuration Release
      - run: dotnet test --configuration Release
```

### Publish (specifický podle typu)
- **NuGet:** Separate workflow s `dotnet pack` + `dotnet nuget push`
- **Web služby:** Self-hosted runner + `./deploy/deploy.sh` + systemd restart
- **Desktop:** Create GitHub Release + upload binaries

## Co dál?

1. **Urči typ svého projektu** podle tabulky výše
2. **Otevři příslušnou dokumentaci:**
   - [ci-cd-nuget-packages-cz.md](ci-cd-nuget-packages-cz.md)
   - [ci-cd-web-services-cz.md](ci-cd-web-services-cz.md)
   - [ci-cd-desktop-apps-cz.md](ci-cd-desktop-apps-cz.md)
3. **Implementuj CI/CD** podle checklist v dokumentaci
```

#### 2. `ci-cd-nuget-packages-cz.md` (RENAME z `ci-cd-pipeline-setup-cz.md`)

**Změny:**
- Přejmenovat soubor
- Přidat na začátek:
  ```markdown
  # CI/CD pro NuGet balíčky
  
  > **Typ projektu:** Knihovny publikované na NuGet.org
  > 
  > **Příklady:** TextToSpeech, Mediation, SystemTray
  > 
  > **Jiný typ projektu?** Viz [ci-cd-overview-cz.md](ci-cd-overview-cz.md)
  ```

- Přidat sekci "Multi-package repositories":
  ```markdown
  ## Multi-package repositories
  
  ### Automatická detekce balíčků
  
  `dotnet pack` automaticky najde VŠECHNY projekty, které mají:
  - `<IsPackable>true</IsPackable>` (nebo není explicitně `false`)
  - NuGet metadata (`<PackageId>`, `<Version>`, ...)
  
  **Příklad: TextToSpeech**
  ```
  TextToSpeech/
  ├── src/                                  # PUBLIKUJE SE
  │   ├── TextToSpeech.Core/                → Olbrasoft.TextToSpeech.Core.nupkg
  │   ├── TextToSpeech.Providers/           → Olbrasoft.TextToSpeech.Providers.nupkg
  │   └── TextToSpeech.Orchestration/       → Olbrasoft.TextToSpeech.Orchestration.nupkg
  └── examples/                             # NEPUBLIKUJE SE
      └── TextToSpeech.Demo/                ← <IsPackable>false</IsPackable>
  ```
  
  ### Workflow pro multi-package
  
  ```yaml
  - name: Collect packages
    run: |
      mkdir -p ./artifacts
      find . -name "*.nupkg" -path "*/bin/Release/*" -exec cp {} ./artifacts/ \;
  
  - name: List packages
    run: ls -la ./artifacts/
  
  - name: Publish to NuGet.org
    run: |
      dotnet nuget push ./artifacts/*.nupkg \
        --source https://api.nuget.org/v3/index.json \
        --api-key ${{ secrets.NUGET_API_KEY }} \
        --skip-duplicate
  ```
  
  **Výsledek:** Publikuje se VŠECHNO v `./artifacts/` najednou.
  ```

#### 3. `ci-cd-web-services-cz.md` (RENAME z `deployment-secrets-guide.md`)

**Změny:**
- Přejmenovat soubor
- Přidat na začátek:
  ```markdown
  # CI/CD pro webové služby a API
  
  > **Typ projektu:** Long-running ASP.NET Core aplikace (REST API, SignalR, Blazor Server)
  > 
  > **Příklady:** VirtualAssistant, GitHub.Issues, Push-To-Talk API
  > 
  > **Jiný typ projektu?** Viz [ci-cd-overview-cz.md](ci-cd-overview-cz.md)
  ```

- Obsah zůstává stejný (deployment-secrets-guide.md je perfektní pro web služby)

#### 4. `ci-cd-desktop-apps-cz.md` (NOVÝ)

```markdown
# CI/CD pro desktopové aplikace

> **Typ projektu:** GUI aplikace (WinForms, WPF, Avalonia, MAUI)
> 
> **Distribuce:** GitHub Releases, .deb balíčky, AppImage
> 
> **Jiný typ projektu?** Viz [ci-cd-overview-cz.md](ci-cd-overview-cz.md)

## Overview

Desktopové aplikace se distribuují jako binárky, které si uživatelé stahují a spouští lokálně.

### Podporované formáty

| Platforma | Formát | Workflow |
|-----------|--------|----------|
| **Linux** | AppImage | Single-file executable |
| **Linux** | .deb balíček | Debian package manager |
| **Windows** | .exe installer | MSI/NSIS installer |
| **macOS** | .app bundle | DMG image |
| **Cross-platform** | .zip archive | Portable binaries |

## Workflow pattern

### 1. Build workflow (při každém pushu)

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
      run: dotnet build --configuration Release
    
    - name: Test
      run: dotnet test --configuration Release
```

### 2. Release workflow (při vytvoření tagu)

```yaml
name: Release

on:
  push:
    tags:
      - 'v*'  # Trigger on version tags (v1.0.0, v1.2.3, etc.)

jobs:
  release:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup .NET
      uses: actions/setup-dotnet@v4
      with:
        dotnet-version: 10.0.x
    
    - name: Publish Linux x64
      run: |
        dotnet publish src/MyApp/MyApp.csproj \
          -c Release \
          -r linux-x64 \
          --self-contained true \
          -p:PublishSingleFile=true \
          -o ./publish/linux-x64
    
    - name: Publish Windows x64
      run: |
        dotnet publish src/MyApp/MyApp.csproj \
          -c Release \
          -r win-x64 \
          --self-contained true \
          -p:PublishSingleFile=true \
          -o ./publish/win-x64
    
    - name: Create ZIP archives
      run: |
        cd ./publish/linux-x64 && zip -r ../../MyApp-linux-x64.zip . && cd ../..
        cd ./publish/win-x64 && zip -r ../../MyApp-win-x64.zip . && cd ../..
    
    - name: Create GitHub Release
      uses: softprops/action-gh-release@v1
      with:
        files: |
          MyApp-linux-x64.zip
          MyApp-win-x64.zip
        body: |
          Release ${{ github.ref_name }}
          
          **Download:**
          - Linux: `MyApp-linux-x64.zip`
          - Windows: `MyApp-win-x64.zip`
```

## AppImage (Linux single-file executable)

TODO: Přidat návod na vytvoření AppImage

## .deb balíček (Debian/Ubuntu)

TODO: Přidat návod na vytvoření .deb balíčku

## Versioning

### Automatické verzování z Git tagu

```yaml
- name: Extract version from tag
  id: version
  run: |
    VERSION=${GITHUB_REF#refs/tags/v}
    echo "version=$VERSION" >> $GITHUB_OUTPUT

- name: Build with version
  run: |
    dotnet publish \
      -p:Version=${{ steps.version.outputs.version }} \
      -p:AssemblyVersion=${{ steps.version.outputs.version }}
```

### Manuální verzování v .csproj

```xml
<PropertyGroup>
  <Version>1.0.0</Version>
  <AssemblyVersion>1.0.0.0</AssemblyVersion>
  <FileVersion>1.0.0.0</FileVersion>
</PropertyGroup>
```

## Checklist pro desktop aplikace

- [ ] Build workflow pro pull requesty
- [ ] Release workflow pro tagy `v*`
- [ ] Multi-platform publish (Linux, Windows, macOS)
- [ ] ZIP archivy pro GitHub Releases
- [ ] (Optional) AppImage pro Linux
- [ ] (Optional) .deb balíček pro Debian/Ubuntu
- [ ] Version extrahovaná z Git tagu
- [ ] Release notes v GitHub Release

## Reference

- [.NET Publish Documentation](https://learn.microsoft.com/en-us/dotnet/core/deploying/)
- [GitHub Releases](https://docs.github.com/en/repositories/releasing-projects-on-github/managing-releases-in-a-repository)
- [AppImage Documentation](https://appimage.org/)
```

---

## Implementační plán

### Krok 1: Vytvořit rozcestník
- [ ] Vytvořit `ci-cd-overview-cz.md`

### Krok 2: Přejmenovat existující soubory
- [ ] `ci-cd-pipeline-setup-cz.md` → `ci-cd-nuget-packages-cz.md`
- [ ] `deployment-secrets-guide.md` → `ci-cd-web-services-cz.md`

### Krok 3: Upravit existující soubory
- [ ] Přidat "Typ projektu" banner na začátek obou souborů
- [ ] Přidat multi-package sekci do `ci-cd-nuget-packages-cz.md`

### Krok 4: Vytvořit novou dokumentaci
- [ ] Vytvořit `ci-cd-desktop-apps-cz.md` (prozatím base struktura)

### Krok 5: Aktualizovat odkazy
- [ ] Najít všechny odkazy na staré názvy souborů
- [ ] Aktualizovat na nové názvy

### Krok 6: Aktualizovat hlavní README
- [ ] Přidat sekci "CI/CD podle typu projektu"
- [ ] Odkaz na `ci-cd-overview-cz.md` jako entry point

---

## Výhody tohoto rozdělení

### 1. ✅ Jasná struktura podle účelu
**Před:**
"Mám projekt, potřebuji CI/CD... kde to mám hledat?"

**Po:**
"Dělám NuGet balíčky → otevřu `ci-cd-nuget-packages-cz.md`"

### 2. ✅ Eliminace zmatenosti
**Před:**
Developer čte `ci-cd-pipeline-setup-cz.md` (NuGet), ale potřebuje secrets pro web službu → čte i `deployment-secrets-guide.md` → zmatek

**Po:**
Web služba → POUZE `ci-cd-web-services-cz.md` (obsahuje vše včetně secrets)

### 3. ✅ Snadná údržba
Každý typ deploymentu má vlastní soubor → změny v jednom typu neovlivní dokumentaci jiných typů

### 4. ✅ Reference mezi dokumenty
Příklad:
```markdown
# ci-cd-nuget-packages-cz.md

## Demo aplikace v repository

Pokud máš demo konzolovou aplikaci (jako TextToSpeech.Demo), 
přidej do .csproj:

```xml
<IsPackable>false</IsPackable>
```

**Poznámka:** Pokud chceš demo distribuovat jako standalone aplikaci,
viz [ci-cd-desktop-apps-cz.md](ci-cd-desktop-apps-cz.md).
```

### 5. ✅ Škálovatelnost
Budoucí typy deploymentu (Docker, Azure, AWS, ...) = nové soubory bez změny existujících

---

## Co říkáš?

Souhlasíš s tímto rozdělením? Mám implementovat tyto změny?

1. ✅ Vytvořit rozcestník `ci-cd-overview-cz.md`
2. ✅ Přejmenovat existující soubory
3. ✅ Přidat multi-package sekci do NuGet dokumentace
4. ✅ Vytvořit base strukturu pro desktop aplikace
5. ✅ Aktualizovat odkazy

Nebo chceš ještě něco upravit v návrhu?
