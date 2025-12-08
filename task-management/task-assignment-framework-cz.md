# Framework pro zadávání úkolů

Praktický průvodce pro přípravu dobře definovaných úkolů pro vývojáře. Soustřeď se na **CO** a **PROČ**, **JAK** nech na programátorovi.

## Rozdělení rolí

| Role | Analytik | Programátor |
|------|----------|-------------|
| **Odpovědnost** | Analyzuje, navrhuje, vytváří úkoly, testuje | Implementuje, ladí, nasazuje |
| **Zaměření** | CO & PROČ | JAK |
| **Výstup** | Dobře definované úkoly s akceptačními kritérii | Funkční kód |

### Co analytik dělá
- Chápe a popisuje problém
- Definuje požadavky z pohledu uživatele
- Stanovuje měřitelná akceptační kritéria
- Testuje výsledek (API volání, ověření UI)
- Reportuje chyby s očekávaným vs skutečným chováním

### Co analytik NEDĚLÁ
- Nerozhoduje o implementaci (schéma databáze, architektura)
- Neladí kód
- Nevybírá konkrétní technologie nebo knihovny

---

## Šablona úkolu

```markdown
## Shrnutí
[Jedna věta: Co je potřeba udělat a proč]

## User Story
Jako [persona/role] chci [akce/funkce], abych [přínos/hodnota].

## Kontext
- Současný stav: [Co existuje nyní]
- Problém: [Co je špatně nebo chybí]
- Související: #číslo_issue (pokud existuje)

## Požadavky
### Musí mít
- [ ] Požadavek 1
- [ ] Požadavek 2

### Mělo by mít (pokud zbyde čas)
- [ ] Volitelné vylepšení

## Akceptační kritéria
- [ ] Když [kontext], pokud [akce], pak [očekávaný výsledek]
- [ ] Když [kontext], pokud [akce], pak [očekávaný výsledek]

## Mimo rozsah
- Co tento úkol NEZAHRNUJE
```

---

## Kontrolní seznam před zadáním úkolu

### Srozumitelnost
- [ ] Lze pochopit bez dodatečného kontextu?
- [ ] Žádné nejednoznačné výrazy (vyhýbej se "mělo by", "možná", "pravděpodobně")?
- [ ] Napsáno jazykem uživatele, ne technickým žargonem?

### Úplnost
- [ ] Je jasné KDO má prospěch?
- [ ] Je definováno CO je potřeba udělat?
- [ ] Je vysvětleno PROČ je to potřeba?
- [ ] Jsou akceptační kritéria měřitelná?

### Rozsah
- [ ] Je úkol dostatečně malý na dokončení v jedné session?
- [ ] Žádné skryté závislosti?
- [ ] Je definováno co je mimo rozsah?

### Testovatelnost
- [ ] Lze ověřit nezávisle?
- [ ] Jsou kritéria úspěchu objektivní?

---

## Pracovní postup

```
1. ANALYZUJ
   - Porozuměj problému
   - Prozkoumej pokud je potřeba
   - Identifikuj kdo má prospěch

2. DEFINUJ
   - Napiš user story
   - Vyjmenuj požadavky (CO, ne JAK)
   - Stanov akceptační kritéria

3. VALIDUJ
   - Projdi kontrolním seznamem
   - Odstraň implementační detaily
   - Zkontroluj nejednoznačnosti

4. ZADEJ
   - Vytvoř GitHub issue
   - Označ vhodně
   - Odkaz na nadřazené issues pokud existují

5. OVĚŘ
   - Otestuj funkcionalitu (API/CLI/UI)
   - Funguje → Uzavři issue
   - Nefunguje → Komentář: "Testováno X, očekáváno Y, dostali jsme Z"
```

---

## Příklady

### Dobrý popis úkolu
> **Shrnutí:** Uživatelé potřebují vidět informace o svém profilu.
>
> **User Story:** Jako přihlášený uživatel chci zobrazit svůj profil, abych mohl ověřit údaje o svém účtu.
>
> **Požadavky:**
> - Zobrazit jméno, email a avatar uživatele
> - Ukázat datum registrace
> - Vrátit odpovídající chybu pokud uživatel neexistuje
>
> **Akceptační kritéria:**
> - Když mám platné ID uživatele a požádám o profil, pak dostanu jméno, email, URL avataru a datum registrace
> - Když mám neplatné ID uživatele a požádám o profil, pak dostanu chybu 404

### Špatný popis úkolu (Příliš technický)
> Vytvoř endpoint `GET /api/users/{id}/profile` pomocí UserRepository patternu. Použij DTO s AutoMapperem. Ulož avatar do Azure Blob Storage s CDN cachováním.

**Proč je to špatně:** Diktuje implementační detaily. Programátor by měl rozhodnout o struktuře endpointu, vzorech a řešení úložiště.

### Špatný popis úkolu (Příliš vágní)
> Oprav tu věc s profilem uživatele

**Proč je to špatně:** Žádný kontext, žádné očekávané chování, žádný způsob jak ověřit úspěch.

---

### Dobrý bug report
> **Testováno:** Profil uživatele pro ID 123
> **Očekáváno:** 200 OK s JSON profilem
> **Dostali jsme:** 500 Internal Server Error
> **Poznámky:** Děje se to pouze u uživatelů vytvořených před rokem 2024

### Špatný bug report
> Profil nefunguje, oprav to prosím

---

## Štítky pro issues

| Štítek | Použití |
|--------|---------|
| `feature` | Nová funkcionalita |
| `bug` | Něco je rozbité |
| `enhancement` | Vylepšení existující funkce |
| `refactor` | Úprava kódu, bez změny chování |
| `docs` | Pouze dokumentace |

---

## Klíčové principy

### DĚLEJ
- Piš z pohledu uživatele
- Piš implementačně neutrální požadavky (CO, ne JAK)
- Zahrnuj akceptační kritéria
- Prioritizuj požadavky (musí mít / mělo by mít)
- Rozděl velké úkoly na menší

### NEDĚLEJ
- Nespecifikuj schéma databáze nebo strukturu tabulek
- Nevybírej frameworky nebo knihovny
- Nedefinuj cesty API endpointů ani HTTP metody
- Nedělej architektonická rozhodnutí
- Nepoužívej nejednoznačný jazyk ("mělo by fungovat", "možná bude potřeba")

---

## Reference

- [Atlassian User Stories Guide](https://www.atlassian.com/agile/project-management/user-stories)
- [Mountain Goat Software - User Stories](https://www.mountaingoatsoftware.com/agile/user-stories)
