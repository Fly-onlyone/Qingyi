# Report layout

Write `report\vm-test-<yyyy-MM-dd>\report.md` beside the evidence the test script saved.
Everything the report says must point at a file in that folder.

```
report\vm-test-<date>\
  report.md
  screenshots\NN-<case>.png
  recording\session.mp4
  logs\results.json, run.log, facts-*.json, vm.json
```

## Sections, in this order

1. **Summary.** What was tested (package name, version, commit), where (guest Windows
   build, VM size, hypervisor), the counts, and the verdict in two or three sentences. A
   reader who stops here knows whether the package can ship.
2. **Findings.** One table: number, severity, one-line statement, state (open, fixed in
   this run, not a defect). Worst first.
3. **One section per finding.** What a user sees, how it was reproduced, the evidence
   (screenshot inline, output quoted), the cause with file and line when known, and a
   suggested fix. Say plainly when the cause is a guess.
4. **What worked.** The cases that passed, each with its evidence.
5. **Not tested.** What the run could not cover and why (no graphics processor in the
   guest, no network service, a click target that moves).
6. **Test rig.** Host, guest, how to run it again: the exact commands.
7. **Evidence index.** Every file, with one line on what it shows.

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
meant to produce. Embed with a relative path:

```
![The app after the first start from the Start menu](screenshots/05-first-start.png)
```
