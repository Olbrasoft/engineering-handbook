# Průvodce Code Review a Refaktoringem pro .NET/C#

Kompletní průvodce prováděním code review a refaktoringu v .NET/C# projektech, v souladu s doporučeními Microsoftu a nejlepšími praktikami pro rok 2025.

> **Zdroje:** Tento průvodce vychází z [Microsoft Engineering Fundamentals Playbook](https://microsoft.github.io/code-with-engineering-playbook/code-reviews/recipes/csharp/), [Microsoft C# Coding Conventions](https://learn.microsoft.com/dotnet/csharp/fundamentals/coding-style/coding-conventions) a [Framework Design Guidelines](https://learn.microsoft.com/dotnet/standard/design-guidelines/).

---

## Proces Code Review

### Účel Code Review

1. **Najít chyby včas** - Zachytit problémy před nasazením do produkce
2. **Sdílení znalostí** - Šířit porozumění kódové bázi
3. **Udržovat konzistenci** - Zajistit dodržování týmových standardů
4. **Zlepšit návrh** - Identifikovat architektonická vylepšení
5. **Dokumentace** - Vytvořit záznam o návrhových rozhodnutích

### Přístup k Review

| Role | Zaměření |
|------|----------|
| **Autor** | Být otevřený zpětné vazbě, vysvětlit kontext, reagovat rychle |
| **Reviewer** | Být konstruktivní, klást otázky, zaměřit se na problémy ne styl |

---

## Checklist pro Code Review

### 1. SOLID Principy

| Princip | Co kontrolovat |
|---------|----------------|
| **Single Responsibility (SRP)** | Má třída/metoda pouze JEDEN důvod ke změně? |
| **Open/Closed (OCP)** | Lze chování rozšířit bez modifikace existujícího kódu? |
| **Liskov Substitution (LSP)** | Mohou být odvozené třídy použity místo základních? |
| **Interface Segregation (ISP)** | Jsou rozhraní malá a zaměřená? Žádná "tlustá" rozhraní? |
| **Dependency Inversion (DIP)** | Závisí kód na abstrakcích, ne na konkrétních implementacích? |

**Varovné signály:**
- Třída s 500+ řádky kódu
- Metoda s 50+ řádky kódu
- Název třídy obsahuje "Manager", "Helper", "Utility", "Common"
- Metoda s 5+ parametry
- Konstruktor s 5+ závislostmi

### 2. Konvence pojmenování (Microsoft styl)

| Element | Konvence | Příklad |
|---------|----------|---------|
| Třídy, Struktury, Rozhraní | PascalCase | `CustomerService`, `IOrderRepository` |
| Metody | PascalCase | `GetCustomerById()` |
| Veřejné vlastnosti | PascalCase | `FirstName`, `IsActive` |
| Privátní pole | _camelCase | `_customerRepository` |
| Lokální proměnné | camelCase | `orderTotal`, `isValid` |
| Parametry | camelCase | `customerId`, `orderDate` |
| Konstanty | PascalCase | `MaxRetryCount`, `DefaultTimeout` |
| Rozhraní | I + PascalCase | `IDisposable`, `IUserService` |
| Async metody | Přípona "Async" | `GetDataAsync()`, `SaveAsync()` |

**Kvalita pojmenování:**
- Názvy by měly odhalovat záměr: `GetActiveCustomers()` ne `GetData()`
- Vyhýbat se zkratkám: `customer` ne `cust`
- Být konzistentní: Nemíchat `Get`, `Fetch`, `Retrieve` pro stejný koncept

### 3. Kvalita kódu

#### Async/Await
- [ ] Je `await` použit správně (ne `.Result` nebo `.Wait()`)?
- [ ] Jsou `CancellationToken` parametry poskytnuty tam, kde je potřeba?
- [ ] Je `Task.WhenAll` použit pro paralelní operace?
- [ ] Končí název async metody příponou `Async`?

#### Zpracování výjimek
- [ ] Jsou zachyceny specifické výjimky (ne `catch (Exception)`)?
- [ ] Je informace o výjimce zachována při opětovném vyhození?
- [ ] Jsou výjimky logovány s dostatečným kontextem?
- [ ] Je použit vzor `using` pro `IDisposable` objekty?

#### Dependency Injection
- [ ] Je DI použita místo `new` pro závislosti?
- [ ] Jsou služby registrovány se správným lifetime (Singleton/Scoped/Transient)?
- [ ] Jsou pro závislosti použita rozhraní, ne konkrétní třídy?

#### Výkon
- [ ] Je LINQ použito vhodně (ne pro jednoduché smyčky)?
- [ ] Existují potenciální problémy s alokací paměti (boxing, krátkodobé objekty)?
- [ ] Jsou databázové dotazy optimalizovány (N+1 problém, chybějící indexy)?
- [ ] Je `StringBuilder` použit pro spojování řetězců ve smyčkách?

### 4. Architektura & Návrh

| Aspekt | Otázky k položení |
|--------|-------------------|
| **Coupling** | Je kód volně provázaný? Mohou být komponenty nahrazeny? |
| **Cohesion** | Zůstávají související věci pohromadě? |
| **Testovatelnost** | Lze tento kód snadno unit testovat? |
| **Rozšiřitelnost** | Mohou být přidány nové funkce bez modifikace existujícího kódu? |

#### Návrhové vzory k hledání

**Creational (Vytvářecí):**
- Factory Pattern pro vytváření objektů
- Builder pro konstrukci složitých objektů

**Structural (Strukturální):**
- Adapter pro integraci externích API
- Decorator pro přidávání chování

**Behavioral (Behaviorální):**
- Strategy pro zaměnitelné algoritmy
- Observer pro událostmi řízenou komunikaci

### 5. Bezpečnost

- [ ] Je vstup validován a sanitizován?
- [ ] Jsou SQL dotazy parametrizované (žádné spojování řetězců)?
- [ ] Jsou tajné údaje uloženy bezpečně (User Secrets, Key Vault)?
- [ ] Jsou citlivá data logována vhodně?
- [ ] Jsou kontroly autentizace/autorizace na místě?

---

## Pokrytí Unit Testy

### Doporučené cíle pokrytí

| Typ projektu | Minimální pokrytí | Cílové pokrytí |
|--------------|-------------------|----------------|
| Business logika | 80% | 90%+ |
| Datová vrstva | 70% | 80% |
| Controllery/API | 60% | 70% |
| UI komponenty | 50% | 60% |

> **Průmyslový standard:** 80% pokrytí kódu je běžně akceptovaný cíl pro firemní projekty. Dokumentace Microsoftu sama zmiňuje udržování 90% pokrytí jako příklad.

### Kvalita vs Kvantita pokrytí

**Důležité:** Vysoké pokrytí nezaručuje kvalitní testy!

```
ŠPATNĚ (100% pokrytí, 0% hodnota):
[Fact]
public void Test()
{
    var service = new MyService();
    service.DoSomething(); // Žádné asserty!
}

DOBŘE (smysluplný test):
[Fact]
public void CalculateTotal_WithDiscount_ReturnsReducedPrice()
{
    var calculator = new PriceCalculator();
    
    var result = calculator.CalculateTotal(100, discount: 0.1m);
    
    Assert.Equal(90, result);
}
```

### Konvence pojmenování testů

```
[Metoda]_[Scenář]_[OčekávanýVýsledek]
```

**Příklady:**
- `GetCustomer_WithValidId_ReturnsCustomer`
- `CreateOrder_WithEmptyCart_ThrowsException`
- `CalculateDiscount_ForPremiumMember_Returns20Percent`

### Vzor Arrange-Act-Assert

```csharp
[Fact]
public void Add_TwoNumbers_ReturnsSum()
{
    // Arrange (Příprava)
    var calculator = new Calculator();
    
    // Act (Akce)
    var result = calculator.Add(2, 3);
    
    // Assert (Ověření)
    Assert.Equal(5, result);
}
```

---

## Pravidla pro Refaktoring

### Kdy refaktorovat

| Spouštěč | Akce |
|----------|------|
| Detekován code smell | Refaktorovat okamžitě |
| Přidávání nové funkce | Nejprve refaktorovat, pak přidat funkci |
| Oprava chyby | Refaktorovat pro prevenci podobných chyb |
| Feedback z code review | Refaktorovat před mergem |

### Běžné Code Smells

| Smell | Řešení |
|-------|--------|
| **Dlouhá metoda** (50+ řádků) | Extrahovat metody |
| **Velká třída** (500+ řádků) | Rozdělit na menší třídy |
| **Duplicitní kód** | Extrahovat do sdílené metody/třídy |
| **Magická čísla** | Nahradit pojmenovanými konstantami |
| **Hluboké zanoření** (3+ úrovně) | Early returns, extrahovat metody |
| **God Class** | Aplikovat Single Responsibility |
| **Feature Envy** | Přesunout metodu do třídy, kterou nejvíce používá |
| **Primitive Obsession** | Vytvořit value objekty |

### Bezpečné kroky refaktoringu

1. **Zajistit existenci testů** - Nikdy nerefaktorovat bez pokrytí testy
2. **Dělat malé změny** - Jeden refaktoring najednou
3. **Spouštět testy často** - Po každé malé změně
4. **Commitovat často** - Malé, zaměřené commity
5. **Zkontrolovat vlastní změny** - Před odesláním k review

### Techniky refaktoringu

#### Extract Method
```csharp
// Před
public void ProcessOrder(Order order)
{
    // Validace
    if (order == null) throw new ArgumentNullException(nameof(order));
    if (order.Items.Count == 0) throw new InvalidOperationException("Empty order");
    
    // Výpočet
    var total = order.Items.Sum(i => i.Price * i.Quantity);
    var tax = total * 0.21m;
    
    // Uložení
    _repository.Save(order);
}

// Po
public void ProcessOrder(Order order)
{
    ValidateOrder(order);
    var total = CalculateTotal(order);
    _repository.Save(order);
}

private void ValidateOrder(Order order) { ... }
private decimal CalculateTotal(Order order) { ... }
```

#### Replace Conditional with Polymorphism
```csharp
// Před
public decimal CalculateDiscount(Customer customer)
{
    switch (customer.Type)
    {
        case CustomerType.Regular: return 0.05m;
        case CustomerType.Premium: return 0.15m;
        case CustomerType.VIP: return 0.25m;
        default: return 0;
    }
}

// Po
public interface IDiscountStrategy
{
    decimal GetDiscount();
}

public class RegularDiscount : IDiscountStrategy
{
    public decimal GetDiscount() => 0.05m;
}
```

---

## Nástroje pro analýzu kódu

### Požadované analyzátory

Přidejte do projektů přes `common.props`:

```xml
<ItemGroup>
    <PackageReference Include="Microsoft.CodeAnalysis.NetAnalyzers" Version="9.0.0">
        <PrivateAssets>all</PrivateAssets>
        <IncludeAssets>runtime; build; native; contentfiles; analyzers</IncludeAssets>
    </PackageReference>
    <PackageReference Include="StyleCop.Analyzers" Version="1.2.0-beta.556">
        <PrivateAssets>all</PrivateAssets>
        <IncludeAssets>runtime; build; native; contentfiles; analyzers</IncludeAssets>
    </PackageReference>
</ItemGroup>

<PropertyGroup>
    <TreatWarningsAsErrors>true</TreatWarningsAsErrors>
    <EnforceCodeStyleInBuild>true</EnforceCodeStyleInBuild>
</PropertyGroup>
```

### EditorConfig

Použijte `.editorconfig` pro vynucení stylových pravidel napříč týmem:

```ini
[*.cs]
# Pojmenování
dotnet_naming_rule.private_fields_should_be_camel_case.severity = error
dotnet_naming_style.camel_case_underscore.required_prefix = _
dotnet_naming_style.camel_case_underscore.capitalization = camel_case

# Styl kódu
csharp_style_var_for_built_in_types = false:warning
csharp_prefer_braces = true:error
```

---

## Souhrn checklistu pro review

### Před odesláním k review

- [ ] Kód se kompiluje bez varování
- [ ] Všechny testy prochází
- [ ] Nový kód má testy (80%+ pokrytí)
- [ ] Žádné natvrdo zapsané tajné údaje nebo connection stringy
- [ ] SOLID principy dodrženy
- [ ] Konvence pojmenování dodrženy
- [ ] Žádná magická čísla/řetězce
- [ ] Async metody správně pojmenované
- [ ] Zpracování výjimek je specifické
- [ ] Zdroje jsou správně uvolňovány

### Během review

- [ ] Dělá kód to, co tvrdí?
- [ ] Je logika správná?
- [ ] Jsou ošetřeny okrajové případy?
- [ ] Je kód čitelný?
- [ ] Mohlo by to být jednodušší?
- [ ] Jsou zde bezpečnostní obavy?
- [ ] Jsou zde výkonnostní obavy?

---

## Reference

- [Microsoft C# Coding Conventions](https://learn.microsoft.com/dotnet/csharp/fundamentals/coding-style/coding-conventions)
- [Microsoft C# Naming Conventions](https://learn.microsoft.com/dotnet/csharp/fundamentals/coding-style/identifier-names)
- [Microsoft Unit Testing Best Practices](https://learn.microsoft.com/dotnet/core/testing/unit-testing-best-practices)
- [Microsoft Engineering Fundamentals - C# Code Reviews](https://microsoft.github.io/code-with-engineering-playbook/code-reviews/recipes/csharp/)
- [Framework Design Guidelines](https://learn.microsoft.com/dotnet/standard/design-guidelines/)
- [SOLID principy](../solid-principles/solid-principles-2025-cz.md)
- [Návrhové vzory](../design-patterns/gof-design-patterns-2025-cz.md)
