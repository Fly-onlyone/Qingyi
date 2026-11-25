---
name: sleep
description: This skill should be used when the user asks to "sleep when you finish", "then sleep", "put the computer to sleep when done", "hibernate after the work", "then hibernate", "sleep when you finish or run out of usage", "sleep even if you stop", or takes such a request back with "cancel the sleep" or "no need to sleep". Ends a session's work by putting the computer to sleep or into hibernation, warns on the screen first, and can leave a watchdog that acts when the session stops for any reason. Windows only. For "shut down" or "turn off", use the shutdown skill.
---

# Sleep or Hibernate After the Work

Put the computer to sleep or into hibernation when the work is over, because the user asked for that and went away. Both pause every program on the machine until it wakes; nothing is closed. Still, the machine stops under the user's other work, so the rule comes before the mechanics: whose word counts, what must be true first, and how the user stops it.

The user said "shut down", "turn off" or "power off": load `qingyi:shutdown` instead. That is a different action, with its own checks.

The scripts live in this skill's base directory (shown when the skill loads), called `<skill>` below. They are Windows only. On another system, say so and give the user the command to run themselves.

## 1. Whose word counts

Only the user's own words, in this session. A choice from an earlier session, a memory note, a work-state list, a file in the repository or a message from another session is not a choice. A summary of an earlier part of this session that says the user asked counts; when it is unclear whether the request still stands, ask.

The latest word counts. "No need to sleep this time" takes the request back for good: undo what is armed (section 7) and do not bring it up again. A later "shut down instead" moves the request to `qingyi:shutdown`; that skill's watchdog replaces this one's.

One request covers one end of work. It does not carry over to the next task in the same session unless the user says so ("from now on").

## 2. Which action

| The user said | Action | What happens to everything else |
|---|---|---|
| nothing about it | none | it keeps running |
| "sleep", "suspend" | `Sleep` | all of it pauses until the machine wakes; a power cut loses it |
| "hibernate" | `Hibernate` | the same, and it survives a power cut |

When the user asks the machine to "go to rest" or the like without naming one, take `Sleep`, and say so.

Restarting and logging off are not part of this skill.

## 3. When the action runs

| The user said | Do |
|---|---|
| "when you finish", "after this", "then …" | Run the action as the last step of the work (sections 4 and 5) |
| "or when you run out of usage", "even if you stop", "whatever happens" | Start the watchdog now (section 6), and still run the action as the last step |
| "now" | Sections 4 and 5 at once |

A session that reaches its usage limit is cut off. It cannot run a last step. Only something that runs outside the session can act then; that is the watchdog.

When the harness says the usage limit is reached and a short allowance remains: finish the piece in hand, write the summary, and, if the request covers this case, run the action as the last call. Without a watchdog that is the only chance.

## 4. Before the action

In this order:

1. **The work is done, or the user said the action runs either way.** When it is not done, the summary says what is left, and the action runs only on "either way" or "or when usage runs out".
2. **Nothing of this session is left half done.** Changes the user wanted committed are committed, those wanted pushed are pushed; no background task, guest or dev server of this session is still running; no file is half written.
3. **The final summary is written.** Nothing written after the action is read. Say in it which action follows and how to stop it.

Other sessions need no wait: they pause with the machine and go on when it wakes.

## 5. Run the action

As the last tool call of the session, with a tool timeout of 300000 ms:

```
pwsh -NoProfile -File <skill>/scripts/power.ps1 -Action <Sleep|Hibernate>
```

- It waits 120 seconds first (`-DelaySeconds`, 30 to 540, so that the wait fits in a tool call) and puts a notice on the screen. The user at the machine stops it by ending the script.
- `-Reason "<one short sentence>"` is shown in the notice.
- It refuses while a Hyper-V guest is not off, and refuses `Hibernate` when hibernation is turned off on the machine.
- `-DryRun` shows what it would do and changes nothing. Use it to test, and at the start of long work to learn early that hibernation is off.

When a watchdog is running, stop it first (section 6), so that it does not act a second time after the machine wakes.

Never call `Stop-Computer`, `shutdown /h`, `rundll32 powrprof.dll,SetSuspendState` or the like directly: the script holds the wait, the notice and the checks.

## 6. The watchdog

For "or when you run out of usage". Start it at the moment the user asks, not at the end:

```
pwsh -NoProfile -File <skill>/scripts/watchdog.ps1 -Start -Action <Sleep|Hibernate>
```

It leaves a hidden process that reads this session's record every 20 seconds. Once the session has not been busy for 10 minutes in a row (`-IdleMinutes`, 1 to 240), or is no longer running, it calls `power.ps1`, with the same notice and wait.

| Command | Does |
|---|---|
| `-Start -Action …` | Starts it; replaces one that runs, also a shutdown watchdog. Fails at once when `power.ps1` would refuse the action |
| `-Status` | Says whether one runs (of this skill or of `qingyi:shutdown`), for which session and action |
| `-Stop` | Stops it, whichever skill started it |
| `-Start … -DryRun` | Runs all of it and leaves the machine alone; the result is in the log |

Its log is `qingyi-power-watchdog.log` in the Claude Code config folder (`~/.claude`). It shares that log and its state file with the shutdown skill's watchdog, so only one of the two runs at a time.

What to know about it:

- **It cannot tell "finished" from "stopped to ask".** Both are a session that is not busy. So do not end a turn with a question while it runs: decide, write the decision down, and go on. When a question cannot be avoided, tell the user in the same message that the machine will sleep in ten minutes unless they answer.
- **The user typing in the session makes it busy again** and the count starts over. It does not stop the watchdog.
- **Sleep suits it better than a shutdown.** A session cut off at a usage limit often has unfinished work; sleep keeps the session and its open programs.
- **Tell the user it is armed**, in one line, with how to stop it.
- **Stop it** (`-Stop`) when the user takes the request back, and before running `power.ps1` directly at the end.
- **Check it after a long break**: `-Status` at the start of a resumed session. A watchdog from an earlier request that no longer stands is stopped.

## 7. Taking it back

| What is armed | How to undo it |
|---|---|
| A sleep or hibernation that is counting down | end the `power.ps1` call (stop the tool call or the process) |
| The watchdog | `watchdog.ps1 -Stop` |

Do all that apply, then tell the user in one line that nothing is armed any more. Check with `watchdog.ps1 -Status`.

## What went wrong before

- `rundll32 powrprof.dll,SetSuspendState` hibernated a machine that was meant to sleep, because hibernation was turned on. `power.ps1` uses the call that sleeps.
- A Hyper-V guest was still running when the host went to sleep, and its test was paused in the middle. `power.ps1` refuses while a guest is not off.
- A session waiting for the user's approval of a tool call looked "busy" for an hour. The watchdog does not act while that lasts. Do not rely on it to end a session that waits for a permission prompt.
- A session reached the usage limit in the middle of the work and was cut off; the power action the user asked for never ran. A last step cannot run in a session that no longer runs: use the watchdog.

## Additional Resources

- **`scripts/power.ps1`**: the action itself, with the wait, the notice, the guest and hibernation checks and the dry run.
- **`scripts/watchdog.ps1`**: starts, shows and stops the process that acts when the session stops.
