# Codebase Exploration Techniques

Before writing any code (Phase 2), you must understand the existing environment.

---

## 🔍 Exploration Checklist

1. **Identify Entry Points:** Where does the execution start? (e.g., `Program.cs`, Controller, Event Handler).
2. **Follow the Data:** How does the data move through the system? Trace the model from DB to UI.
3. **Recognize Patterns:** Do we use Dependency Injection, CQRS, or Repository pattern here?
4. **Identify Dependencies:** What external services or libraries does this feature rely on?

---

## 🛠 Tools for Exploration

- **`grep` / `search_file_content`:** Find keyword usage across the codebase.
- **`codebase_investigator`:** Get a high-level architectural overview.
- **`ls -R` / `list_directory`:** Understand the folder structure.

---

## 📦 Examples from Olbrasoft Projects

### Tracing TTS Flow

**Project:** NotificationAudio  
**What it demonstrates:** Tracing from interface to concrete implementation.

When exploring how audio is played:
1. Start at `INotificationPlayer.cs` (Interface).
2. Find implementations: `NotificationPlayer.cs`.
3. Trace provider usage: `IPlaybackProvider` -> `PaplayProvider.cs`.

**Lesson learned:** Always start at the Abstractions layer to understand the contract before diving into implementation details.

---

## ✅ Before You Start - Code Exploration

- [ ] I've identified the main entry point for the feature.
- [ ] I've found at least one existing file that does something similar.
- [ ] I understand the project's folder structure and where my new code belongs.
- [ ] I've checked `package.json` or `.csproj` for existing libraries I should reuse.
