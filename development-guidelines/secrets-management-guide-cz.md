# Správa Secrets v .NET Aplikacích

## Úvod

Tento průvodce popisuje **doporučené postupy** pro správu citlivých údajů (secrets) v .NET aplikacích podle oficiální dokumentace Microsoftu a průmyslových standardů.

## Co jsou Secrets?

Secrets jsou citlivé údaje, které **NIKDY** nesmí být uloženy v kódu nebo verzovacím systému:

- **API klíče** (OpenAI, Cohere, VoiceRSS, GitHub tokens)
- **Hesla k databázím**
- **Connection stringy obsahující hesla**
- **OAuth Client Secrets**
- **Přihlašovací údaje třetích stran**

## Základní Pravidla

### ❌ NIKDY

```json
// ❌ appsettings.json - NIKDY takto!
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=mydb;User=sa;Password=MySecretPassword123"
  },
  "OpenAI": {
    "ApiKey": "sk-proj-abc123def456..."
  }
}
```

### ✅ SPRÁVNĚ

```json
// ✅ appsettings.json - Pouze struktura
{
  "ConnectionStrings": {
    "DefaultConnection": "" // Hodnota z User Secrets nebo env proměnné
  },
  "OpenAI": {
    "ApiKey": "" // Hodnota z User Secrets nebo env proměnné
  }
}
```

## Vývojové Prostředí (Development)

### User Secrets

Microsoft doporučuje **User Secrets** pro lokální vývoj. Secrets jsou uloženy **mimo** projekt v uživatelském profilu.

#### Inicializace User Secrets

```bash
cd ~/projekty/MojeAplikace/src/MojeAplikace.Web
dotnet user-secrets init
```

Vytvoří v `.csproj`:
```xml
<PropertyGroup>
  <UserSecretsId>aspnet-MojeAplikace-20250116-1234</UserSecretsId>
</PropertyGroup>
```

#### Ukládání Secrets

```bash
# Connection string
dotnet user-secrets set "ConnectionStrings:DefaultConnection" \
  "Server=localhost;Database=mydb;User=sa;Password=DevPassword123"

# API klíč
dotnet user-secrets set "OpenAI:ApiKey" "sk-proj-abc123..."

# Vnořené hodnoty
dotnet user-secrets set "GitHub:ClientSecret" "ghp_abc123..."
```

#### Kde jsou uloženy?

```
~/.microsoft/usersecrets/<UserSecretsId>/secrets.json
```

Příklad obsahu:
```json
{
  "ConnectionStrings:DefaultConnection": "Server=localhost;Database=mydb;User=sa;Password=DevPassword123",
  "OpenAI:ApiKey": "sk-proj-abc123...",
  "GitHub:ClientSecret": "ghp_abc123..."
}
```

#### Použití v Kódu

```csharp
// Program.cs - žádné změny potřeba!
var builder = WebApplication.CreateBuilder(args);

// Configuration API automaticky načítá User Secrets ve Development módu
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
var apiKey = builder.Configuration["OpenAI:ApiKey"];
```

#### Výhody User Secrets

- ✅ Secrets **mimo** verzovací systém
- ✅ Automaticky načítány v Development módu
- ✅ Specifické pro každého vývojáře
- ✅ Žádné změny v kódu

#### Seznam Secrets

```bash
# Zobrazit všechny secrets
dotnet user-secrets list

# Odstranit secret
dotnet user-secrets remove "OpenAI:ApiKey"

# Smazat všechny secrets
dotnet user-secrets clear
```

## Produkční Prostředí (Production)

### Environment Variables

Pro produkci Microsoft doporučuje **environment variables**. Jsou bezpečnější než soubory a podporovány všemi cloud platformami.

#### Systemd Service (Linux)

Nejlepší způsob je **Environment File**:

**1. Vytvořit soubor s secrets** (mimo repozitář):
```bash
# /etc/systemd/system/mojeaplikace.env
ConnectionStrings__DefaultConnection=Server=localhost;Database=proddb;User=sa;Password=ProdPassword123
OpenAI__ApiKey=sk-proj-xyz789...
GitHub__ClientSecret=ghp_xyz789...
```

**Důležité:** Použít `__` (dvojité podtržítko) místo `:` v názvech!

**2. Nastavit oprávnění:**
```bash
sudo chmod 600 /etc/systemd/system/mojeaplikace.env
sudo chown root:root /etc/systemd/system/mojeaplikace.env
```

**3. Odkázat v systemd service:**
```ini
# /etc/systemd/system/mojeaplikace.service
[Unit]
Description=Moje Aplikace

[Service]
Type=notify
User=jirka
WorkingDirectory=/opt/olbrasoft/mojeaplikace
ExecStart=/usr/bin/dotnet /opt/olbrasoft/mojeaplikace/MojeAplikace.dll
EnvironmentFile=/etc/systemd/system/mojeaplikace.env
Environment="ASPNETCORE_ENVIRONMENT=Production"

[Install]
WantedBy=multi-user.target
```

**4. Restart služby:**
```bash
sudo systemctl daemon-reload
sudo systemctl restart mojeaplikace.service
```

#### Přímé Environment Variables

Alternativně přímo v service souboru (méně doporučeno):

```ini
[Service]
Environment="ConnectionStrings__DefaultConnection=Server=localhost;..."
Environment="OpenAI__ApiKey=sk-proj-..."
```

### Cloud Platformy

#### Azure

**Azure Key Vault** - doporučené řešení pro produkci:

```bash
# Instalace balíčku
dotnet add package Azure.Extensions.AspNetCore.Configuration.Secrets
```

```csharp
// Program.cs
var builder = WebApplication.CreateBuilder(args);

if (builder.Environment.IsProduction())
{
    var keyVaultEndpoint = new Uri(builder.Configuration["KeyVaultEndpoint"]!);
    builder.Configuration.AddAzureKeyVault(keyVaultEndpoint, new DefaultAzureCredential());
}
```

#### AWS

**AWS Secrets Manager**:

```bash
dotnet add package AWSSDK.SecretsManager
```

## Connection Strings

### Správný Formát

```bash
# Development (User Secrets)
dotnet user-secrets set "ConnectionStrings:DefaultConnection" \
  "Server=localhost;Database=devdb;User=sa;Password=DevPass123;TrustServerCertificate=True"

# Production (Environment Variable)
ConnectionStrings__DefaultConnection="Server=prod-server;Database=proddb;User=sa;Password=ProdPass123;Encrypt=True"
```

### Použití v Kódu

```csharp
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");

builder.Services.AddDbContext<MyDbContext>(options =>
    options.UseSqlServer(connectionString));
```

## GitHub OAuth

### Development

```bash
dotnet user-secrets set "GitHub:ClientId" "Ov23liabcdef"
dotnet user-secrets set "GitHub:ClientSecret" "1234567890abcdef..."
```

### Production

```ini
# /etc/systemd/system/mojeaplikace.env
GitHub__ClientId=Ov23liabcdef
GitHub__ClientSecret=1234567890abcdef...
```

## API Klíče

### Development

```bash
dotnet user-secrets set "OpenAI:ApiKey" "sk-proj-..."
dotnet user-secrets set "Cohere:ApiKey" "cohere-api-..."
dotnet user-secrets set "VoiceRSS:ApiKey" "abc123..."
```

### Production

```ini
# /etc/systemd/system/mojeaplikace.env
OpenAI__ApiKey=sk-proj-...
Cohere__ApiKey=cohere-api-...
VoiceRSS__ApiKey=abc123...
```

## .gitignore

Zajistit, že secrets soubory **NIKDY** nejsou v gitu:

```gitignore
# .gitignore

# User Secrets (už jsou mimo projekt)
appsettings.Development.json  # Pokud obsahuje secrets
appsettings.Production.json   # Pokud obsahuje secrets

# Environment files
*.env
secrets.env

# Adresáře se secrets (pokud použijete vlastní řešení)
Dokumenty/přístupy/
.secrets/
```

## Kontrola před Commitem

```bash
# Zkontrolovat, že v gitu nejsou secrets
git diff | grep -i "password\|apikey\|secret"

# Prohledat všechny soubory
grep -r "Password=" --include="*.json" --include="*.cs"
```

## Migrace ze Souborů

Pokud aktuálně používáte soubory s secrets (např. `~/Dokumenty/přístupy/`), doporučený postup migrace:

### Development

```bash
# 1. Načíst hodnoty ze souborů
OPENAI_KEY=$(cat ~/Dokumenty/přístupy/openai.txt)
COHERE_KEY=$(cat ~/Dokumenty/přístupy/cohere.txt)

# 2. Uložit do User Secrets
cd ~/projekty/MojeAplikace/src/MojeAplikace.Web
dotnet user-secrets set "OpenAI:ApiKey" "$OPENAI_KEY"
dotnet user-secrets set "Cohere:ApiKey" "$COHERE_KEY"

# 3. Smazat soubory (volitelné)
# rm ~/Dokumenty/přístupy/*.txt
```

### Production

```bash
# 1. Vytvořit environment file
sudo nano /etc/systemd/system/mojeaplikace.env

# 2. Přidat secrets (použít __ místo :)
OpenAI__ApiKey=...
Cohere__ApiKey=...

# 3. Nastavit oprávnění
sudo chmod 600 /etc/systemd/system/mojeaplikace.env

# 4. Aktualizovat service
sudo systemctl daemon-reload
sudo systemctl restart mojeaplikace.service
```

## Testování Konfigurace

### Ověřit, že secrets jsou načteny

```csharp
// Program.cs nebo Startup.cs
var openAiKey = builder.Configuration["OpenAI:ApiKey"];
if (string.IsNullOrEmpty(openAiKey))
{
    throw new InvalidOperationException("OpenAI:ApiKey není nakonfigurovaný!");
}
```

### Logování (BEZ zobrazení hodnot!)

```csharp
var logger = app.Services.GetRequiredService<ILogger<Program>>();
logger.LogInformation("OpenAI API klíč je {Status}",
    string.IsNullOrEmpty(openAiKey) ? "CHYBÍ" : "NASTAVEN");
// ❌ NIKDY: logger.LogInformation("API key: {Key}", openAiKey)
```

## Shrnutí

| Prostředí | Metoda | Umístění | Příklad |
|-----------|--------|----------|---------|
| **Development** | User Secrets | `~/.microsoft/usersecrets/<id>/` | `dotnet user-secrets set` |
| **Production (Linux)** | Environment File | `/etc/systemd/system/*.env` | `EnvironmentFile=` v systemd |
| **Production (Cloud)** | Key Vault | Azure Key Vault / AWS Secrets Manager | `AddAzureKeyVault()` |

## Reference

- [Microsoft: Safe storage of app secrets in development](https://learn.microsoft.com/en-us/aspnet/core/security/app-secrets)
- [Microsoft: Configuration in ASP.NET Core](https://learn.microsoft.com/en-us/aspnet/core/fundamentals/configuration/)
- [Code-Maze: .NET Configuration Best Practices](https://code-maze.com/dotnet-configuration-best-practices/)
