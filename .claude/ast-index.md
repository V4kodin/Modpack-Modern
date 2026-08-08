# ast-index Rules

## Installation

Install via Homebrew:

```bash
brew tap defendend/ast-index
brew install ast-index
```

## Working Directory (CRITICAL)

**ALWAYS run `ast-index` from the project root**, not from a parent workspace directory.

Each project has its own index. Always `cd` into the project root before running any command:

```bash
cd /path/to/your/project && ast-index <command>
```

**NEVER** run from a parent directory — the index won't be found.

### First-time setup

```bash
cd /path/to/your/project
ast-index rebuild
```

After `git pull` or major changes:

```bash
ast-index update
```

## Mandatory Search Rules

1. **ALWAYS use ast-index FIRST** for any code search task
2. **NEVER duplicate results** — if ast-index found usages/implementations, that IS the complete answer
3. **DO NOT run grep "for completeness"** after ast-index returns results
4. **Use grep/Grep tool ONLY when:**
   - ast-index returns empty results
   - Searching for regex patterns (ast-index uses literal match)
   - Searching for string literals inside code (`"some text"`)
   - Searching in comments content

## Rules for Subagents (Agent tool)

**CRITICAL: When spawning Explore/Plan agents for code search tasks:**

1. **NEVER suggest grep/Grep tool in agent prompts** — always specify ast-index commands
2. **EXPLICITLY FORBID grep** in the prompt: `FORBIDDEN: grep, rg, Grep tool, find`
3. **Provide exact ast-index commands** for the task:
   ```
   Use ONLY ast-index (run from project root first):
   - `ast-index file "FileName"` — find file
   - `ast-index usages "SymbolName"` — find usages
   - `ast-index implementations "InterfaceName"` — find implementations
   - `ast-index class "Name"` — find definition
   ```

## Why ast-index

ast-index is 17-69x faster than grep (1-10ms vs 200ms-3s) and returns structured, accurate results.

---

## Core Search Commands

| Command  | Description                                                    | Example                              |
|----------|----------------------------------------------------------------|--------------------------------------|
| `search` | Universal search across files, symbols, modules               | `ast-index search "Payment"`         |
| `file`   | Find files by name (partial match supported)                   | `ast-index file "client.go"`         |
| `symbol` | Find symbols: classes, interfaces, functions, properties       | `ast-index symbol "fetchUser"`       |
| `class`  | Find class or interface definition by exact name               | `ast-index class "ApiClient"`        |

---

## Usage & References

| Command     | Description                                              | Example                                  |
|-------------|----------------------------------------------------------|------------------------------------------|
| `usages`    | Find all usages of a symbol (function, class, property)  | `ast-index usages "AuthService"`         |
| `refs`      | Definitions + imports + usages in one view               | `ast-index refs "Repository"`            |
| `callers`   | Find all places that call a specific function            | `ast-index callers "validateToken"`      |
| `call-tree` | Show call hierarchy tree (recursive)                     | `ast-index call-tree "handleRequest" -d 3` |

---

## Class Hierarchy & Implementations

| Command           | Description                                              | Example                                     |
|-------------------|----------------------------------------------------------|---------------------------------------------|
| `implementations` | Find all classes that extend/implement a type            | `ast-index implementations "Handler"`       |
| `hierarchy`       | Show full class hierarchy (parents and children)         | `ast-index hierarchy "BaseController"`      |

---

## File Analysis

| Command   | Description                                                  | Example                              |
|-----------|--------------------------------------------------------------|--------------------------------------|
| `outline` | Show all symbols in a file (classes, functions, properties)  | `ast-index outline "server.go"`      |
| `imports` | Show all imports in a file                                   | `ast-index imports "main.go"`        |
| `changed` | Show symbols changed in git diff (useful for code review)    | `ast-index changed`                  |

---

## Project Insights

| Command        | Description                                               | Example                                    |
|----------------|-----------------------------------------------------------|--------------------------------------------|
| `map`          | Compact project overview: dirs with symbol kind counts    | `ast-index map`                            |
| `map --module` | Drill down into specific area with full class details     | `ast-index map --module src/api`           |
| `conventions`  | Auto-detect architecture patterns and frameworks          | `ast-index conventions`                    |

---

## Code Quality

| Command          | Description                                     | Example                       |
|------------------|-------------------------------------------------|-------------------------------|
| `todo`           | Find TODO/FIXME/HACK comments in code           | `ast-index todo`              |
| `deprecated`     | Find deprecated items                           | `ast-index deprecated`        |
| `unused-symbols` | Find potentially unused exported symbols        | `ast-index unused-symbols`    |

---

## Index Management

| Command   | Description                         | When to use                     |
|-----------|-------------------------------------|---------------------------------|
| `rebuild` | Full reindex from scratch           | First time, after major changes |
| `update`  | Incremental index update            | After git pull/merge            |
| `stats`   | Show index statistics               | Debugging, verification         |
| `watch`   | Watch for file changes, auto-update | During active development       |

---

## Common Use Cases

```bash
# Where is this symbol used?
ast-index usages "AuthService"

# What implements this interface?
ast-index implementations "Repository"

# What calls this function?
ast-index callers "validateToken"
ast-index call-tree "validateToken" --depth 3

# Explore project structure
ast-index map
ast-index conventions

# Find all TODOs
ast-index todo

# What changed in my branch?
ast-index changed --base main
```

---

## Configuration (.ast-index.yaml)

To exclude generated or build directories, create `.ast-index.yaml` in the project root:

```yaml
exclude:
  - "dist"
  - "build"
  - ".next"
  - "node_modules"
  - "vendor"
  - "bin"
```
