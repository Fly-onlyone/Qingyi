# Report layout

The report is a Claude Artifact: an HTML page published with the `Artifact` tool, with
the run's screenshots and recording published beside it. Write the page source to
`report\vm-test-<yyyy-MM-dd>\report.html`, in the folder the test script filled.
Everything the report says must point at a file in that folder.

```
report\
  vm-test-<date>.html              link file: opens the published report
  vm-test-<date>\
    report.html                    the page source that was published
    screenshots\NN-<case>.png
    recording\session.mp4, session.start.txt
    logs\results.json, run.log, facts-*.json, vm.json
```

## Sections, in this order

1. **Summary.** What was tested (package name, version, commit), where (guest Windows
   build, VM size, hypervisor), the counts, and the verdict in two or three sentences. A
   reader who stops here knows whether the package can ship. Show the counts as a row
   of verdict tiles.
2. **Findings.** One table: number, severity, one-line statement, state (open, fixed in
   this run, not a defect). Worst first. Each row links to its section.
3. **One section per finding.** What a user sees, how it was reproduced, the evidence
   (the screenshots inline, output quoted, a button that plays the recording from the
   case), the cause with file and line when known, and a suggested fix. Say plainly when
   the cause is a guess.
4. **What worked.** The cases that passed, each with its screenshots and a recording
   button.
5. **Recording.** The whole run as one video, with a list of the cases and the time
   each began. Leave the section out, and say why, when the run made no recording.
6. **Not tested.** What the run could not cover and why (no graphics processor in the
   guest, no network service, a click target that moves).
7. **Test rig.** Host, guest, how to run it again: the exact commands.
8. **Evidence index.** Every file, with one line on what it shows. Link the files the
   page publishes; name the logs, which stay in the folder.

## Counting

The script's counts and the report's counts are different things. The script marks a
case `pass`, `fail`, `note` or `error` from exit codes, files and processes. After
reading the screenshots, some `note` cases become pass or fail, and a `pass` can become
a fail (the window opened but the page is blank). Give both counts and say which cases
changed and why.

Use four verdicts: pass, fail, inconclusive, recorded. From the script's statuses:

| Script says | Report says |
|---|---|
| `pass`, `fail` | the same, unless a screenshot shows otherwise |
| `note` | pass or fail after reading its screenshots; recorded when the case only measures something; inconclusive when the screenshots cannot settle it |
| `error` | inconclusive: the harness failed (the VM did not start, a command timed out). Never a failure of the app. Repeat the case by hand if it matters |

## Severity

| Severity | Meaning |
|---|---|
| Blocker | the app cannot be installed or started on a clean machine |
| High | a main function fails, or the app makes the machine unusable |
| Medium | a documented step fails but a workaround exists |
| Low | leftovers, cosmetics, missing diagnostics |

## Screenshots

Read every screenshot before citing it. Describe what is on it, never what the step was
meant to produce. Embed with the relative path the page publishes it at, with the
description as `alt` text and a caption, and link the image to itself for full size:

```html
<figure>
  <a href="screenshots/05-first-start.png"><img src="screenshots/05-first-start.png"
     alt="The app's main window after the first start from the Start menu" loading="lazy"></a>
  <figcaption>05 · E1: the main window after the first start from the Start menu</figcaption>
</figure>
```

## Recording

`logs\results.json` gives each case a `started` time, and `recording\session.start.txt`
holds the time of the film's first picture. A case's position in the film is the
difference in seconds. Cases that ran before the recording started (A1) have none.

Embed one `<video controls preload="metadata">` of the recording, and give each case a
button that seeks it:

```html
<video id="run" controls preload="metadata" src="recording/session.mp4"></video>
<button data-seek="754">Watch C1 from 12:34</button>
<script>
  document.querySelectorAll("[data-seek]").forEach((button) =>
    button.addEventListener("click", () => {
      const video = document.getElementById("run");
      video.currentTime = Number(button.dataset.seek);
      video.scrollIntoView({ behavior: "smooth", block: "center" });
      video.play();
    }));
</script>
```

The times are a second or two late at most: the case's clock starts before its first
command reaches the guest.

## Size limits of an Artifact

Each published file may hold 15 MB, and one publish 64 MB. Check the sizes before
publishing.

- **The recording over 15 MB**: publish a smaller copy as `recording/session.mp4` and
  keep the original in the folder.
  `ffmpeg -i recording\session.mp4 -vf scale=960:-2 -c:v libx264 -preset slow -crf 36 -an recording\session-web.mp4`.
  Still over 15 MB: cut it into parts of ten minutes, each with its own video, and
  point each button at its part and the time within it:
  `ffmpeg -i recording\session-web.mp4 -c:v libx264 -crf 36 -force_key_frames "expr:gte(t,n_forced*600)" -f segment -segment_time 600 -reset_timestamps 1 recording\part-%02d.mp4`.
- **Everything together over 64 MB**: publish the page with the screenshots first, then
  publish again to the same `url` with the recording. A later publish keeps the files
  already there.

## Without an Artifact

When the `Artifact` tool is missing or refuses, write `report.md` in the run folder
instead of `report.html`, and no link file. Keep the same sections and verdicts.

- Embed screenshots with relative paths:
  `![The app's main window after the first start](screenshots/05-first-start.png)`.
- Markdown cannot play a video. Link the recording,
  `[Recording of the whole run](recording/session.mp4)`, and give each case its start
  time in the film as text (`C1 · from 12:34`) in place of a button.
- Skip the size limits: nothing is published.
