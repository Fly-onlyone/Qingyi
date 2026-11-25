# Bake and Clean

Run this only after the user confirms the values or the winning variant.

## 0. Starting cold

When cleanup is requested in a new session, or as "remove" with no values given:

1. Find the editor (see the searches in step 4).
2. Read the module's header comment. It names the values the editor tunes, every unmarked
   entry it added (language keys, manifest entries, engine project entries) and where the
   save is.
3. Read the save (`references/stack-recipes.md`, "Auto save", says how per stack). Show the
   user its values and active variant, and ask them to confirm those values or name the
   winning variant. Without a readable save, ask for the values from the panel's values
   block.
4. "Remove" with no values means **revert**: keep the shipped values and delete the editor.

## 1. Write the values where shipped values live

Take the values from the save, for the variant the user confirmed. Its `shipped` block
shows what each value replaces.

| Value type | Where it goes |
|---|---|
| Color, opacity, tint share | The theme or token file, or a named constant next to related style constants |
| Size, spacing, radius | The spacing or size scale; a new token only if no existing step fits |
| Font, weight | The typography tokens or text styles |
| CSS custom property | Its declaration in the stylesheet (`:root` or the theme selector) |
| Resource (WPF/WinUI) | The `ResourceDictionary` entry |
| Per-theme values | Every theme file that defines the key, not just the one on screen |

- Keep the project's naming and file layout.
- Each new constant gets a comment that says what it styles. A provenance note such as
  "chosen by eye on <today's date>" is enough. Do not mention the editor, which no longer
  exists.
- Where the editor stored whole units, convert them exactly (`20%` → `0.20`).
- If a baked value breaks a rule the project tests (contrast, for example), adjust the
  dependent colors rather than the rule, and say so in the report.

## 2. Resolve the comparison

- **If one variant won:** delete the losing variant's code path, the variant type or enum,
  the switch control and any setting it read.
- **If the user kept the current look:** delete the candidate path.

Code that existed only to support the comparison goes too.

## 3. Delete the editor

- The editor module file.
- Its declaration or import (`mod`, `import`, project-file entries, registrations).
- Every hook marked `TEMP-STYLE-EDITOR`. Restore each use site to read the baked value
  directly.
- Every unmarked entry listed in the module header (language keys, autoloads, manifest
  entries, `options.txt` lines and the like).
- The panel mount and any provider or wrapper added for it.
- Any dependency added only for the editor (package manifests and lock files).
- The save: the `temp_style_editor` file with any `.tmp` and `temp_style_editor.user.json`
  beside it, or the storage key. Where the agent cannot reach it (a browser's
  `localStorage` without automation, a device that is not connected), tell the user the
  exact command or key to clear.
- Scratch files the checks left behind: screenshots, scratch settings directories, scripts.

## 4. Prove it is gone

The editor module is usually untracked, and a plain `git grep` skips untracked files.
Search with untracked files included, or with ripgrep or the Grep tool, which also cover
projects outside git:

```
git grep --untracked -n "TEMP-STYLE-EDITOR"
git grep --untracked -n -i -E "temp[_-]?style[_-]?editor"
git status --short --ignored
git diff --stat
```

`git grep` matches file contents, not file names, and a save in an ignored folder
(`Saved/`, `run/`) is not untracked but ignored. So also search by name with the Glob
tool, `**/temp_style_editor*`, and look at the save's location from the module header
when it lies outside the project (`user://`, an app container, a device).

- The two `git grep` searches and the name search must find nothing.
- `git status --short --ignored` must show no editor file and no save.
- `git diff --stat` must show only the baked values, the removed hooks, and tests.

## 5. Pin the result with tests

Where the project tests style or themes:

- **Prefer constraint tests:** every text color against the edited surfaces at WCAG AA,
  icons at 3:1, minimum sizes. They catch a later change that breaks the look.
  A test that only repeats a constant adds little.
- If a variant was removed, remove or adapt its tests. Do not keep tests for deleted paths.

## 6. Final checks

1. Run the project's build, formatter, linter and full test suite.
2. Run the app and capture the approved screen without taking focus. Compare it with the
   look the user approved in the editor.
3. Stop only the processes the check started.

## 7. Report

Tell the user, briefly:

- each baked value and the file it lives in;
- what was deleted (module, hooks, switch, entries, dependencies);
- any dependent color adjusted to keep a tested rule;
- the test and check results.

Commit only when the user asks.
