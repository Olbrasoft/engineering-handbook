# GitHub Issues

Průvodce pro efektivní vytváření a správu GitHub issues.

## Obsah

- [Průvodce psaním issues](./issue-writing-guide-cz.md) - Jak psát jasné a realizovatelné specifikace issues

## Rychlý přehled

### Zlaté pravidlo

**Analytik se soustředí na CO a PROČ, Programátor rozhoduje JAK.**

### Kontrolní seznam issue

Před vytvořením jakéhokoliv issue ověř:

1. **Jasný** - Lze pochopit bez kladení dotazů
2. **Úplný** - Má user story, požadavky, akceptační kritéria
3. **Ohraničený** - Definuje co je zahrnuto A co není
4. **Testovatelný** - Úspěch lze objektivně ověřit

### Minimální životaschopný issue

```markdown
## Shrnutí
[Co + Proč v jedné větě]

## User Story
Jako [kdo] chci [co], abych [proč].

## Akceptační kritéria
- [ ] Když X, pokud Y, pak Z
```

---

## Sub-Issues: Správný způsob

**Sub-issues se MUSÍ propojovat přes GitHub funkci sub-issues, NE jako textové reference v těle issue.**

### Špatný způsob

Psaní textových referencí v těle issue:
- "Part of #123"
- "Sub-issue of #123"
- "Parent Issue: #123"

Toto NEVYTVÁŘÍ žádný skutečný vztah v GitHubu. Je to jen text, který někdo musí ručně parsovat a udržovat.

### Správný způsob

Použij nativní propojení sub-issues v GitHubu:

1. **Přes UI**: Otevři rodičovský issue → Klikni na tlačítko "Add sub-issue"
2. **Přes API**: `POST /repos/{owner}/{repo}/issues/{parent_number}/sub_issues` s `{"sub_issue_id": <child_issue_id>}`

### Proč na tom záleží

| Funkce | Textová reference | Nativní Sub-Issue |
|--------|------------------|-------------------|
| Sledování postupu | Ruční počítání | Automatické % dokončení |
| Navigace | Hledání/scrollování | Přímé odkazy oběma směry |
| Reporting | Není možné | Vestavěné přehledy |
| Automatizace | Křehké regex | Spolehlivé API |
| Zavření rodiče | Ruční kontrola | Blokuje pokud nedokončeno |
