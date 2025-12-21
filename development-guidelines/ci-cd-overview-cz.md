# CI/CD Overview - Jaký typ projektu mám?

Tento průvodce ti pomůže vybrat správnou CI/CD strategii podle typu projektu.

---

## 🎯 Rychlé rozhodování

| Typ projektu | Deployment | Dokumentace |
|--------------|------------|-------------|
| **NuGet balíčky** | Publikace na NuGet.org | [ci-cd-nuget-packages-cz.md](ci-cd-nuget-packages-cz.md) |
| **Webové služby/API** | Lokální server (systemd) | [ci-cd-web-services-cz.md](ci-cd-web-services-cz.md) |
| **Desktopové aplikace** | GitHub Releases | [ci-cd-desktop-apps-cz.md](ci-cd-desktop-apps-cz.md) |

---

## Jak poznat typ projektu?

### NuGet balíčky

**Účel:** Knihovna, kterou jiní vývojáři použijí ve svých projektech

**Příklady:** TextToSpeech, Mediation, SystemTray

**Poznávací znaky:**
- ✅ Obsahuje `<PackageId>` v `.csproj`
- ✅ Má `README.md` s "Installation: `dotnet add package ...`"
- ✅ Targetuje `netstandard2.1` nebo multi-targeting
- ❌ NENÍ to samostatně spustitelná aplikace

**Distribuce:** NuGet.org

**Použití:** 
```bash
dotnet add package Olbrasoft.TextToSpeech.Core
```

**CI/CD workflow:**
```
Push na main → Build → Test → Pack → Publish na NuGet.org
```

---

### Webové služby/API

**Účel:** Služba běžící na serveru, přístupná přes HTTP/WebSocket

**Příklady:** VirtualAssistant, GitHub.Issues, Push-To-Talk API

**Poznávací znaky:**
- ✅ Obsahuje ASP.NET Core (`Microsoft.AspNetCore.App`)
- ✅ Má systemd service soubor (`.service`)
- ✅ Běží jako long-running process (daemon)
- ✅ Má `appsettings.json` s connection strings
- ✅ Deploy script (`deploy/deploy.sh`)

**Distribuce:** Deployment na `/opt/olbrasoft/<app>/`

**Použití:**
```bash
curl http://localhost:5055/api/health
```

**CI/CD workflow:**
```
Push na main → Build → Test → Publish binárky → Restart systemd service
```

---

### Desktopové aplikace

**Účel:** GUI aplikace, kterou si uživatelé instalují a spouští lokálně

**Příklady:** WinForms, WPF, Avalonia, MAUI aplikace

**Poznávací znaky:**
- ✅ Obsahuje GUI framework (`Avalonia`, `System.Windows.Forms`)
- ✅ Má entry point (`Main()`) pro standalone spuštění
- ✅ Targetuje `net10.0` (ne `netstandard`)
- ✅ `<OutputType>WinExe</OutputType>` nebo `Exe`

**Distribuce:** GitHub Releases, .deb balíčky, AppImage

**Použití:** 
```bash
# Linux
./MyApp.AppImage

# Windows
MyApp.exe
```

**CI/CD workflow:**
```
Tag v* → Build → Test → Package (AppImage/deb/exe) → Create GitHub Release
```

---

## Lze mít více typů v jednom repozitáři?

**ANO!** Příklad: **TextToSpeech**

### Struktura repozitáře:
```
TextToSpeech/
├── src/                          # NuGet balíčky (PUBLIKUJE SE)
│   ├── TextToSpeech.Core/
│   ├── TextToSpeech.Providers/
│   └── TextToSpeech.Orchestration/
└── examples/                     # Demo aplikace (NEPUBLIKUJE SE)
    └── TextToSpeech.Demo/        # Console app pro testování
```

### Jak to funguje:

**1. `src/*` projekty:**
```xml
<PropertyGroup>
  <PackageId>Olbrasoft.TextToSpeech.Core</PackageId>
  <Version>1.1.0</Version>
  <!-- IsPackable=true je default -->
</PropertyGroup>
```
→ `dotnet pack` vytvoří `.nupkg`  
→ Publikuje se na NuGet.org

**2. `examples/*` projekty:**
```xml
<PropertyGroup>
  <IsPackable>false</IsPackable>
</PropertyGroup>
```
→ `dotnet pack` je PŘESKOČÍ  
→ Pouze build & test

### CI/CD workflow:
```yaml
- name: Collect packages
  run: |
    mkdir -p ./artifacts
    find . -name "*.nupkg" -path "*/bin/Release/*" -exec cp {} ./artifacts/ \;

- name: Publish to NuGet.org
  run: |
    dotnet nuget push ./artifacts/*.nupkg \
      --api-key ${{ secrets.NUGET_API_KEY }} \
      --skip-duplicate
```

**Výsledek:** Publikují se POUZE projekty v `src/`, demo aplikace se ignorují.

---

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
        with:
          dotnet-version: 10.0.x
      - run: dotnet restore
      - run: dotnet build --configuration Release
      - run: dotnet test --configuration Release
```

**Spouští se vždy** - ověří, že kód funguje.

### Publish (specifický podle typu)

| Typ | Workflow | Trigger |
|-----|----------|---------|
| **NuGet** | `dotnet pack` + `dotnet nuget push` | Push na `main` nebo tag `v*` |
| **Web služby** | `./deploy/deploy.sh` + systemd restart | Self-hosted runner na `main` |
| **Desktop** | Create GitHub Release + upload binaries | Tag `v*` |

---

## Rozhodovací strom

```
Mám .NET projekt
│
├─ Má GUI? (WinForms/WPF/Avalonia)
│  └─ ANO → Desktop aplikace → ci-cd-desktop-apps-cz.md
│
├─ Má ASP.NET Core? (API/WebApp)
│  └─ ANO → Webová služba → ci-cd-web-services-cz.md
│
└─ Je to knihovna? (class library)
   └─ ANO → NuGet balíček → ci-cd-nuget-packages-cz.md
```

---

## Co dál?

### 1. Urči typ svého projektu

Použij tabulku nebo rozhodovací strom výše.

### 2. Otevři příslušnou dokumentaci

- **NuGet balíčky:** [ci-cd-nuget-packages-cz.md](ci-cd-nuget-packages-cz.md)
- **Webové služby:** [ci-cd-web-services-cz.md](ci-cd-web-services-cz.md)
- **Desktopové aplikace:** [ci-cd-desktop-apps-cz.md](ci-cd-desktop-apps-cz.md)

### 3. Implementuj CI/CD

Každá dokumentace obsahuje:
- ✅ Checklist kontroly
- ✅ Workflow šablony (copy/paste ready)
- ✅ Troubleshooting
- ✅ Příklady z existujících Olbrasoft projektů

---

## Reference

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [NuGet Package Documentation](https://learn.microsoft.com/en-us/nuget/)
- [ASP.NET Core Deployment](https://learn.microsoft.com/en-us/aspnet/core/host-and-deploy/)
- [.NET Application Publishing](https://learn.microsoft.com/en-us/dotnet/core/deploying/)
