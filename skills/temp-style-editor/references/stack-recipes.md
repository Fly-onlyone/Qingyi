# Stack Recipes

For each stack, this file gives:
- where the value store lives;
- how a change reaches the screen;
- where to mount the panel;
- how to keep it out of release builds;
- where the auto save lives and how to write it (section "Auto save");
- how to capture the result without taking the user's focus;
- what to remove afterwards.

The names below are long-stable primitives. Still, check every API against the docs for the
version the project pins before using it. Frameworks rename and deprecate.

General rule for every stack: when the project already routes style through variables
(CSS custom properties, theme tokens, resource dictionaries), tune those variables. The
framework then redraws on its own, and the hooks shrink to almost nothing.

## Auto save

Every editor saves each change to one save named `temp_style_editor` and loads it on start
(the rules are in SKILL.md, "Auto save"). For every stack:

- **Contents**: `{ "variant": "<active>", "variants": { "<name>": { "<key>": <value> } },
  "shipped": { "<key>": <value> }, "changed": "<ISO time>" }`. Store whole units (percent,
  pixels, token names) as the controls do.
- **Path**: a file save goes in the project root unless the table says otherwise. Resolve it
  at compile time where the stack can (the table names how), or else write it as an
  absolute path constant in the editor module. The module is temporary, so a
  machine-specific path is fine.
- **Atomic write**: write `<save>.tmp`, then rename it over the save. Where the rename does
  not replace an existing file, delete the old save first, then rename.
- **No new dependency** when the stack can do without one. Without built-in JSON, write
  `key=value` lines to `temp_style_editor.txt`. A dependency added only for the save goes at
  cleanup, like any other.
- **Removal**: every stack's removal also deletes the save, and any `.tmp` or
  `temp_style_editor.user.json` beside it.

| Stack | Where the save lives | Write and read | Read back and delete |
|---|---|---|---|
| Web, Electron and Tauri renderers, webviews | `localStorage` key `temp_style_editor` (atomic already) | `localStorage.setItem('temp_style_editor', JSON.stringify(state))`; `JSON.parse(localStorage.getItem('temp_style_editor'))` | In the app's origin, through browser automation: `localStorage.getItem(...)`, then `localStorage.removeItem('temp_style_editor')`. Without automation, ask the user to run them in the dev tools console |
| Rust (GPUI, egui, ratatui) | `concat!(env!("CARGO_MANIFEST_DIR"), "/temp_style_editor.json")` | `serde_json` if the project has it, else `key=value` lines; `std::fs::write` the `.tmp`, then `std::fs::rename` (replaces on Windows too) | Read and delete the file |
| Qt | An absolute path constant | `QJsonDocument`; `QSaveFile` writes atomically on `commit()` | As Rust |
| WPF, WinUI 3 (.NET) | Project root, found by walking up from the module's `[CallerFilePath]` | `System.Text.Json`; `File.Move(tmp, save, overwrite: true)` on .NET Core 3.0 and later; on .NET Framework, `File.Replace(tmp, save, null)` once the save exists | As Rust. UWP is sandboxed: use `ApplicationData.Current.LocalFolder`, and log the path at start |
| SwiftUI, AppKit (macOS) | Project root from `#filePath`; a sandboxed app writes in its container's Application Support instead, and logs the path at start | `JSONEncoder` / `JSONDecoder`; `data.write(to: url, options: .atomic)` | As Rust |
| Flutter | Desktop: the project root, as an absolute constant. Mobile: `getApplicationDocumentsDirectory()` if the project already has `path_provider` | `jsonEncode` / `jsonDecode`; write the `.tmp`, then `File.rename` | Android: `adb shell run-as <package> cat app_flutter/temp_style_editor.json`, `... rm ...` |
| Jetpack Compose | `File(context.filesDir, "temp_style_editor.json")` | `org.json.JSONObject` (built in); write the `.tmp`, then `renameTo` | `adb shell run-as <package> cat files/temp_style_editor.json`, `... rm ...` (debug builds only) |
| SwiftUI (iOS) | The Documents directory | As macOS | `xcrun simctl get_app_container booted <bundle-id> data`, then `Documents/temp_style_editor.json` |
| React Native | `AsyncStorage` or `MMKV` if the project has one, key `temp_style_editor`; else add one for the editor only | `JSON.stringify` / `JSON.parse` | From a debug hook or the values block; clear the key at cleanup |
| Unity | Editor: `Path.Combine(Application.dataPath, "..", "temp_style_editor.json")`, outside `Assets` so nothing is imported. Device builds: `Application.persistentDataPath` | `JsonUtility.ToJson` / `FromJson` on a `[Serializable]` class (no dictionaries: use arrays of key and value); `File.Replace(tmp, save, null)` once the save exists, `File.Move` the first time | As Rust |
| Godot 4 | `user://temp_style_editor.json`; print `ProjectSettings.globalize_path("user://temp_style_editor.json")` at start | `FileAccess.open(path, FileAccess.WRITE)` + `store_string(JSON.stringify(state))`; `JSON.parse_string(FileAccess.get_file_as_string(path))`; `DirAccess.rename_absolute` | Read and delete at the printed path |
| Unreal | `FPaths::ProjectSavedDir() / TEXT("temp_style_editor.json")` (usually ignored by git) | `FFileHelper::SaveStringToFile` / `LoadFileToString`; JSON through the `Json` module if the project uses it, else `key=value` lines; `IFileManager::Get().Move(Dest, Src, true)` | Read and delete in `Saved/` |
| Minecraft mods | Fabric: `FabricLoader.getInstance().getGameDir().resolve("temp_style_editor.json")`; NeoForge and Forge: `FMLPaths.GAMEDIR.get().resolve(...)`. In development that is the `run` folder | Gson (ships with Minecraft); `Files.writeString` the `.tmp`, then `Files.move(tmp, save, StandardCopyOption.REPLACE_EXISTING, StandardCopyOption.ATOMIC_MOVE)` | Read and delete in `run/` |
| Terminal UI | The project root (an absolute constant, since the working directory varies) | Python `json` + `os.replace`; Go `encoding/json` + `os.Rename`; Node `JSON` + `fs.renameSync`; Rust as above | As Rust |

## Web

| Framework | Value store | Redraw | Dev-only gate |
|---|---|---|---|
| Plain HTML/CSS | CSS custom properties: `document.documentElement.style.setProperty('--name', value)` | Automatic | Load the editor script only in dev |
| React | Module store read with `useSyncExternalStore`, or `useState` in a provider at the root | Automatic for readers of the store; a component that reads a module constant must switch to the hook | `import.meta.env.DEV` (Vite), `process.env.NODE_ENV !== 'production'` |
| React Native | As React | As React | `__DEV__` |
| Vue 3 | `reactive({...})` exported from the editor module | Automatic | `import.meta.env.DEV` (Vite), `process.env.NODE_ENV` (Vue CLI) |
| Svelte | A writable store (Svelte 3/4), or an exported `$state` object whose fields change (Svelte 5 cannot reassign an exported `$state`) | Automatic | `import.meta.env.DEV` |
| Angular | `signal()` in a service | Automatic in templates that read the signal | `isDevMode()` |

- **Panel:** a fixed-position element mounted once at the root (`position: fixed`, a high
  `z-index`, a corner that hides nothing being judged). Mount it from the editor module
  behind the dev gate.
- **Electron / Tauri / webviews:** use the web recipe inside the renderer.
- **Screenshot:** a browser-automation tool running headless (Playwright
  `page.screenshot()`), or a browser MCP tool. Drive the controls with the tool's click on
  the panel's buttons.
- **Remove:** the panel mount, the provider or store import at the root, and the marked
  `var(--x)` or hook reads. CSS variables that were already part of the design stay.

## Desktop

### Rust: GPUI
- **Store:** a `Copy` struct implementing `Global`. Read it with `cx.try_global::<T>()`
  (fall back to the defaults). Write it with `cx.set_global(value)`.
- **Redraw:** in each view that reads the values, subscribe once with
  `cx.observe_global::<T>(|_, cx| cx.notify())`. Views drawn as cached views otherwise keep
  their last frame. Window-level state derived from the values (for example glass opacity)
  must be recomputed in `render`.
- **Panel:** a section in an existing side pane, or a row in a toolbar.
- **Gate:** `#[cfg(debug_assertions)]` on the module and its hooks, with a release getter
  that returns the shipped constant.
- **Remove:** the `mod` line, the module file, the marked getter calls and the panel child.

### Rust: egui
- **Store:** a struct in app state.
- **Panel:** an `egui::Window`.
- **Redraw:** call `ctx.request_repaint()` after a change.

### Qt
- **Widgets:** a `QObject` singleton holding the values and emitting a `changed` signal.
  Connected widgets call `update()`. Build the panel as a `QDockWidget` with `QSlider`,
  `QComboBox` and `QPushButton`.
- **QML:** a singleton `QtObject` with properties. It needs `pragma Singleton` plus
  registration (a `singleton` line in `qmldir`, or `QT_QML_SINGLETON_TYPE` in CMake).
  Bindings redraw automatically.
- **Gate:** a debug-only define, or `#ifndef QT_NO_DEBUG`.
- **Remove:** the dock widget or QML file, the singleton registration, and the marked
  bindings.

### WPF
- **Store:** resources in a `ResourceDictionary`. Change them with
  `Application.Current.Resources["Key"] = value`.
- **Redraw:** only `{DynamicResource Key}` follows a change. `{StaticResource}` does not, so
  a marked hook may switch a use site to `DynamicResource` temporarily.
- **Panel:** a separate small tool `Window`.
- **Gate:** `#if DEBUG`.
- **Remove:** the tool window, and restore any use site switched to `DynamicResource` only
  for the editor.

### WinUI 3 and UWP
- **No `{DynamicResource}`:** replacing `Application.Current.Resources["Key"]` does not
  update existing `StaticResource` or `ThemeResource` uses.
- **Change values in place instead:** for example
  `((SolidColorBrush)Application.Current.Resources["Key"]).Color = c`. Or bind with
  `x:Bind ... Mode=OneWay` to a store that implements `INotifyPropertyChanged`.
- **Panel:** a separate window.
- **Gate:** `#if DEBUG`.
- **Clicks:** WinUI handles pointer input as `WM_POINTER`, so posted mouse messages may be
  ignored. Drive the store from a debug hook instead.

### SwiftUI and AppKit (macOS)
- **SwiftUI:** an `@Observable` class (Swift 5.9 / macOS 14 and later) or an
  `ObservableObject` with `@Published`. Inject it through the environment. Views that
  read it redraw.
- **AppKit:** post a notification on change, and set `needsDisplay = true` on the affected
  views.
- **Panel:** a separate window or an inspector pane.
- **Gate:** `#if DEBUG`.

### Screenshots without focus on desktop
- **Windows:**
  - Capture with `PrintWindow(hwnd, hdc, 2)`, where flag 2 is `PW_RENDERFULLCONTENT`, which
    GPU-drawn windows need.
  - Click with `PostMessage` `WM_MOUSEMOVE`, `WM_LBUTTONDOWN` and `WM_LBUTTONUP` at
    client coordinates (convert with `ScreenToClient`). Coordinates are physical pixels in
    per-monitor DPI-aware windows. Apps that read `WM_POINTER` or raw input ignore posted
    mouse messages.
  - Mica and acrylic backdrops are not captured. Paint a known backdrop color under a
    debug flag before judging translucent surfaces.
- **macOS:** `screencapture -x -o -l <windowID>`. `-o` drops the shadow. Get the window ID
  from `CGWindowListCopyWindowInfo`. The terminal needs the Screen Recording permission.
- **Linux X11:** `import -window <id> shot.png` (ImageMagick) or `xwd -id <id>`. Under
  Wayland the method depends on the compositor; ask the user before capturing.
- **Clean up:** start the app with a scratch settings or profile directory, so a theme or
  preference changed during the check does not overwrite the user's own. Stop only the
  processes the check started; record their IDs first.

## Mobile

| Framework | Store | Redraw | Gate | Panel |
|---|---|---|---|---|
| Flutter | `ValueNotifier` or `ChangeNotifier` | `ValueListenableBuilder` / `ListenableBuilder` around readers | `kDebugMode` | An `OverlayEntry` or a debug drawer |
| Jetpack Compose | `mutableStateOf` in an object | Composables that read it recompose | `(context.applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) != 0` (AGP 8 no longer generates `BuildConfig` by default) | A debug bottom sheet |
| SwiftUI (iOS) | As on macOS | As on macOS | `#if DEBUG` | A sheet or overlay |
| React Native | As React | As React | `__DEV__` | An absolutely positioned view |

- **Screenshots:**
  - Android: `adb shell screencap -p /sdcard/shot.png`, then `adb pull /sdcard/shot.png`.
    Redirecting `adb exec-out` output in Windows PowerShell 5.1 corrupts the PNG.
  - Android taps: `adb shell input tap x y`.
  - iOS simulator: `xcrun simctl io booted screenshot shot.png`. The simulator has no tap
    command, so drive the store from a debug hook.
  - Flutter: `flutter screenshot`.

## Games

### Unity
- **Store:** a static class.
- **Avoid ScriptableObject assets for the store:** edits made to one in play mode are written
  back to the asset, as are `sharedMaterial` edits. Work on runtime copies (`Instantiate`,
  `material` rather than `sharedMaterial`).
- **Redraw:** apply the values in `Update`, or when they change.
- **Panel:** an IMGUI overlay in a dev-only `MonoBehaviour` that draws `GUILayout.Button`
  and `GUILayout.HorizontalSlider` in `OnGUI()`.
- **Spawning:** create the overlay from a `[RuntimeInitializeOnLoadMethod]` so no scene
  file references it. Removal then leaves no missing script behind.
- **Gate:** `#if UNITY_EDITOR || DEVELOPMENT_BUILD`.
- **Screenshot:** `ScreenCapture.CaptureScreenshot(path)`. The editor stops rendering when
  unfocused unless Run In Background is on.

### Godot 4
- **Store:** an autoload script holding the values and emitting a `changed` signal.
- **Panel:** a `CanvasLayer` with `HSlider`, `OptionButton` and `Button`.
- **Gate:** `OS.is_debug_build()`.
- **Screenshot:** `get_viewport().get_texture().get_image().save_png(path)`.
- **Remove:** also delete the autoload entry in `project.godot`. Godot rewrites that file
  and drops comments, so list the entry in the module header.

### Unreal
- **Store:** console variables (`TAutoConsoleVariable`) read where the style is applied.
- **Panel:** a dev-only UMG widget for readouts and the A/B switch. Without one, values
  change only from the console.
- **Gate:** `#if !UE_BUILD_SHIPPING`.
- **Screenshot:** `HighResShot 1`.

### Minecraft mods (Fabric, NeoForge, Forge)
- **Store:** a static holder in client-only code: Fabric's `client` source set, or a class
  referenced only from `Dist.CLIENT` code.
- **Panel:** a `Screen` subclass with button widgets.
  - **Keep the world visible behind it:** a `Screen` pauses singleplayer by default and
    dims or blurs the world (1.20.5 and later). Override the pause check (`shouldPause`
    in Yarn, `isPauseScreen` in Mojang mappings) to return false, and override
    `renderBackground` to draw nothing. A HUD overlay is the alternative.
  - **Open it with a client command.** A key binding writes to `options.txt`. If one is
    used anyway, add that line to the removal list.
  - **Relabel buttons** with `setMessage` after a change.
- **Redraw:**
  - Screens and HUD redraw every frame.
  - Chunk-meshed content keeps its old colors until the chunks rebuild: block tints from
    color providers, baked models. After a change, rebuild them:
    `worldRenderer.reload()` in Yarn, or `levelRenderer.allChanged()` in Mojang mappings.
  - Use the project's mappings for every name.
- **Gate:** the loader's development flag. Fabric:
  `FabricLoader.getInstance().isDevelopmentEnvironment()`. NeoForge and Forge: the
  `FMLEnvironment` production flag (check its form for the version).
- **Screenshot without focus:** call the screenshot API from a client command
  (`ScreenshotRecorder.saveScreenshot` in Yarn, `Screenshot.grab` in Mojang mappings;
  check the signature for the version). F2 needs focus.
- **Remove:** the command or key binding registration, its language-file entries, and the
  `options.txt` line if any.

## Terminal UI (ratatui, Bubble Tea, Textual, Ink)
- **Store:** the values live in app state.
- **Keys:** Tab picks the value to change, `[` and `]` step it, `c` cycles, and `v`
  switches the variant. Check every key against the app's existing keymap first.
- **Readout:** show the values in a status line.
- **Redraw:** happens on the next render tick.
- **Gate:** a debug build flag or an environment variable read at start.
- **Screenshot:** run inside tmux and capture with colors using
  `tmux capture-pane -p -e -t <target>`. Drive it with `tmux send-keys -t <target> ']'`.
  Textual can also save an SVG with `App.save_screenshot()`.
- **Remove:** the key bindings, the status-line segment and the gate.
