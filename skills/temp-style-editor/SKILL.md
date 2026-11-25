---
name: temp-style-editor
description: >-
  This skill should be used when the user asks to "let me tune the colors", "tune by eye",
  "add a temporary editor", "add live style controls", "adjust colors in the app",
  "try sizes or spacing in the app", "add a temporary switch to compare", "A/B the look"
  or "compare with the current look", or, for an editor this skill built, "keep these
  values", "bake in the values", "remove the temporary editor" or "remove every
  temporary editor". Builds throwaway in-app controls (color cycles, -/value/+ steppers,
  an A/B switch, contrast readouts) behind one marker, TEMP-STYLE-EDITOR, auto-saves every
  change so a restart keeps it, lets the user choose by eye, then bakes the confirmed values
  into the shipped code and removes every trace, the save included. Works with any stack:
  web, desktop, mobile, games (including Minecraft mods), TUI.
---

# Temporary Style Editor

Give the user throwaway controls inside the running app to choose colors, sizes,
strengths or variants by eye. Once the user confirms a choice, write the chosen values
where the shipped values live and delete the editor completely.

The editor is scaffolding: it never ships, saves only to its own `temp_style_editor` save,
and leaves the tuned surfaces exactly as they were until the user touches a control. One
name and one marker make every piece of it findable.

## Phase 0: Scope

1. **Ask what to tune** with `AskUserQuestion`, skipping whatever the request already
   answers:
   - which elements (page background, quotes, headings, buttons, chrome, ...);
   - which properties (color, strength or opacity, size, spacing, font, variant);
   - whether to compare against the current look with an A/B switch.

   Offer "live tuning controls" and "describe the change" as separate options. If the user
   picks "describe the change", leave this skill and make the edit directly.
2. **Find where each value lives today**: constants, theme or token files, CSS custom
   properties, style sheets, resource dictionaries, config. Record each current value; it
   becomes the editor's default.
3. **Detect the stack and its UI layer** from build files and entry points, then read
   `references/stack-recipes.md` for that stack.
4. **Capture a baseline screenshot** of the screens to be tuned before touching any code.
   Phase 2 compares against it.
5. **Reuse the project's own controls.** Draw the panel with the project's design system
   or component library, and read the project's agent instructions for component rules.

## Phase 1: Build

### One name, one marker

- Name the module, the store type and the panel type `temp_style_editor` in the stack's
  casing (`temp_style_editor.rs`, `tempStyleEditor.ts`, `TempStyleEditor.cs`). Start the
  module with a comment saying it is temporary, which values it tunes, and that it goes
  once the user confirms.
- Mark every hook outside the module (a value read, the panel mount, a switch) with the
  comment `TEMP-STYLE-EDITOR` on the same or the preceding line.
- Some entries cannot hold a comment: JSON language files, package manifests, lock files,
  engine project files the editor rewrites. Name such entries with `temp_style_editor`
  (for example a lang key `key.<modid>.temp_style_editor`) and list each one in the
  module's header comment.
- Keep hooks few: a getter call in place of a constant, one panel mount, one switch.

### Value store

- Hold the values in a runtime-mutable store the UI reads while rendering. The recipe per
  stack is in `references/stack-recipes.md`.
- **Defaults equal the shipped values**, so with no save present the tuned surfaces render
  exactly as before until a control moves.
- **One value set per variant** when comparing. The switch starts on the current variant.
  Seed the candidate from the user's proposal, or from a copy of the current values. The
  controls edit the active variant, so the switch keeps comparing after tuning.
- Gate the editor to development builds where the stack allows. A gated getter needs a
  release fallback that returns the shipped value.

### Auto save

Build an auto save into every editor. The user's tuning survives an app restart or a crash,
and the agent reads the chosen values from the save instead of asking the user to copy them.

- **Save on every change**: one write per press or cycle, and for a continuous slider one
  write about 300 ms after it stops. "Reset to shipped" and the A/B switch save too.
- **One save, named `temp_style_editor`**: `temp_style_editor.json` in the project root on
  desktop, games and TUI; the `localStorage` key `temp_style_editor` on web; the app's own
  files directory on mobile. Where and how per stack is in `references/stack-recipes.md`.
- **What it holds**: every variant's values, the active variant, the shipped defaults and the
  time of the last change. The shipped defaults let the bake step show what changed.
- **Write it atomically**: write `temp_style_editor.json.tmp`, then rename it over the
  save, so a crash in the middle leaves the last good save.
- **Load it on start**: take known keys whose values are in range; fall back to the
  defaults for the rest. When values came from the save, the panel title says "restored".
- **Behind the same gate** as the editor: a release build never reads or writes it.
- **Nothing else persists**: no app settings, preferences, engine assets or the app's own
  save files.
- **Name the save in the module header comment**, with its full location, so a cold start
  finds it.

### Panel

- Mount it where it moves nothing the user is judging: an overlay, a separate window, or a
  side area that already exists. Give it a hide toggle.
- Title it "(temporary)" with the active variant's name.
- Controls: color cycles from the project's palette, `-`/value/`+` steppers, the A/B
  switch, a "reset to shipped" button, live constraint readouts (contrast against WCAG AA)
  and a values block the user can copy back. Patterns and layout rules are in
  `references/controls.md`.

### Redraw

After each change, notify every view that reads the values. Cached or memoized views keep
their last frame unless told otherwise. The stack recipes name the call.

## Phase 2: Verify

1. Run the project's build, linter, formatter and tests.
2. **Start without a save.** When the user already has one (the editor is being extended),
   rename it to `temp_style_editor.user.json` (web: copy the key's value to
   `temp_style_editor.user`) and put it back in step 7. Never delete or overwrite a save the
   user made.
3. Run the app and capture a screenshot **without taking focus**. Methods are in
   `references/stack-recipes.md`. With the panel hidden and no control moved, the tuned
   surfaces must match the baseline.
4. **Drive the controls programmatically**: post a click or key to the window, or call the
   store from a debug hook, then capture again. Check that the look, the values block and
   the readouts all changed.
5. **Check the auto save.** The save exists and holds the new value. Restart the app: the
   value comes back and the panel title says "restored".
6. **Check that the panel fits.** Library minimum widths can squeeze a row of controls
   unevenly (see `references/controls.md`).
7. Delete the save the check made, and put back the user's save if step 2 moved one aside.
   Stop every process the check started, and only those.

## Phase 3: Hand over

Tell the user, briefly:

- where the controls are and what each one changes;
- that every change is saved at once to the save (name its location), so a restart or a
  crash keeps the tuned look, and "Reset to shipped" goes back;
- to say "keep these" or which variant wins when done; the agent reads the values from the
  save, so nothing needs copying.

Then **wait**. Never bake values in or remove the editor without an explicit confirmation.
Do not commit while the editor is in the tree. If the user asks for a commit, say that the
editor is still in the tree and offer to bake in or remove it first. Never stage the editor
module, a marked hook or the save. If the user asks for another control, extend the editor.

## Phase 4: Bake and clean

Run this only after confirmation. The full checklist is in `references/cleanup.md`.

0. **Starting cold** (a new session, or "remove" with no values given): search for the
   marker and the name, read the module header for what it tunes, which unmarked entries
   it added and where the save is. Read the save, show the user its values, and ask them to
   confirm those values or name the winning variant. "Remove" alone means revert to the
   shipped values, unless the user names values.
1. **Write the confirmed values** where the shipped values live, following the project's
   structure and naming. The save is the source; the values block is the fallback when no
   save can be read.
2. **If a variant won**, delete the losing branch, the switch and the variant type.
3. **Delete the editor**: the module, every marked hook, every entry listed in its header,
   the panel mount, any dependency added only for it, and the save.
4. **Prove it is gone** with searches that include untracked and ignored files, by content
   and by file name. Nothing may match.
5. **Add tests** for the constraints the readouts showed (for example text contrast at AA)
   where the project tests style.
6. **Run the full checks**, capture a final screenshot, and compare it with the look the
   user approved.
7. **Report** the values written, where they live, and what was removed. Commit only when
   the user asks.

## Rules

- One name (`temp_style_editor`), one marker (`TEMP-STYLE-EDITOR`).
- An untouched editor with no save changes nothing on the tuned surfaces.
- Auto save every change to the one `temp_style_editor` save; nothing else persists.
- Never ship the editor or its save, and never commit either.
- Never bake or remove without the user's confirmation.
- Verify APIs for the project's pinned framework versions. The recipes name long-stable
  primitives, but versions differ.

## Additional Resources

### Reference Files

- **`references/stack-recipes.md`**: the value store, redraw call, panel host, dev-only
  gate, auto save location and calls, screenshot without focus, and removal notes per
  stack (web, desktop, mobile, games, TUI).
- **`references/controls.md`**: control patterns, step rounding, contrast formula and
  thresholds, layout rules, reset and hide controls, and the values block.
- **`references/cleanup.md`**: the bake-in checklist, the searches that prove removal, and
  the final checks.
