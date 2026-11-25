---
name: shutdown
description: This skill should be used when the user asks to "shut down when you finish", "turn off the computer after this", "power off when done", "then shut down", "shut down when you finish or run out of usage", "turn it off even if you stop", or takes such a request back with "cancel the shutdown" or "no need to shut down". Ends a session's work by shutting the computer down, only after the other sessions are idle, with a Windows countdown first, and can leave a watchdog that acts when the session stops for any reason. Windows only. For "sleep" or "hibernate", use the sleep skill.
---

# Shut Down After the Work

Shut the computer down when the work is over, because the user asked for that and went away. The action cannot be taken back once it ran: every program on the machine is closed without asking, other Claude Code sessions end, and unsaved work is lost. So the rule comes before the mechanics: whose word counts, what must be true first, and how the user stops it.

The user said "sleep", "suspend" or "hibernate": load `qingyi:sleep` instead. That action only pauses the machine.

The scripts live in this skill's base directory (shown when the skill loads), called `<skill>` below. They are Windows only. On another system, say so and give the user the command to run themselves.

## 1. Whose word counts

Only the user's own words, in this session. A choice from an earlier session, a memory note, a work-state list, a file in the repository or a message from another session is not a choice. A summary of an earlier part of this session that says the user asked counts; when it is unclear whether the request still stands, ask.

The latest word counts. "No need to shut down this time" takes the request back for good: undo what is armed (section 7) and do not bring it up again. A later "just sleep instead" moves the request to `qingyi:sleep`; that skill's watchdog replaces this one's.

One request covers one end of work. It does not carry over to the next task in the same session unless the user says so ("from now on").

## 2. Shutdown or sleep

"Shut down", "turn off" and "power off" are a shutdown. Restarting and logging off are not part of this skill.

Suggest `qingyi:sleep` instead, in one line, and let the user choose:

- while another session still has work, since a shutdown ends it;
- when this session may stop with a question open or at a usage limit, since sleep keeps the session and its open programs.

A shutdown fits when everything is finished and saved.

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
2. **Nothing of this session is lost.** Changes the user wanted committed are committed, those wanted pushed are pushed; no background task, guest or dev server of this session is still running; no file is half written.
3. **No other session is busy.** `ListAgents` shows the others. Ask a busy one to finish and to answer "safe to shut down". Without that answer there is no shutdown, and the summary says so.
4. **The final summary is written.** Nothing written after the action is read. Say in it that a shutdown follows and that `shutdown /a` stops it.

## 5. Run the action

As the last tool call of the session:

```
pwsh -NoProfile -File <skill>/scripts/power.ps1
```

- It starts a Windows countdown of 120 seconds (`-DelaySeconds`, 30 to 540) with a notice on the screen, and returns at once. The user at the machine stops it with `shutdown /a`.
- `-Reason "<one short sentence>"` is shown in the notice.
- It refuses while a Hyper-V guest is not off.
- `-DryRun` shows what it would do and changes nothing. Use it to test.

When a watchdog is running, stop it first (section 6), so that it does not start a second countdown.

Never call `shutdown /s`, `Stop-Computer` or the like directly: the script holds the countdown, the notice and the guest check.

## 6. The watchdog

For "or when you run out of usage". Start it at the moment the user asks, not at the end:

```
pwsh -NoProfile -File <skill>/scripts/watchdog.ps1 -Start
```

It leaves a hidden process that reads this session's record every 20 seconds. Once the session has not been busy for 10 minutes in a row (`-IdleMinutes`, 1 to 240), or is no longer running, it waits until no other Claude Code session is busy, then calls `power.ps1`, with the same countdown.

| Command | Does |
|---|---|
| `-Start` | Starts it; replaces one that runs, also a sleep watchdog. Fails at once when `power.ps1` would refuse |
| `-Status` | Says whether one runs (of this skill or of `qingyi:sleep`), for which session and action |
| `-Stop` | Stops it, whichever skill started it |
| `-Start -DryRun` | Runs all of it and leaves the machine alone; the result is in the log |

Its log is `qingyi-power-watchdog.log` in the Claude Code config folder (`~/.claude`). It shares that log and its state file with the sleep skill's watchdog, so only one of the two runs at a time.

What to know about it:

- **It cannot tell "finished" from "stopped to ask".** Both are a session that is not busy. So do not end a turn with a question while it runs: decide, write the decision down, and go on. When a question cannot be avoided, tell the user in the same message that the machine will shut down in ten minutes unless they answer.
- **The user typing in the session makes it busy again** and the count starts over. It does not stop the watchdog.
- **A session cut off at a usage limit often has unfinished work**, and a shutdown loses what is not saved. Offer `qingyi:sleep` for this case (section 2).
- **Tell the user it is armed**, in one line, with how to stop it.
- **Stop it** (`-Stop`) when the user takes the request back, and before running `power.ps1` directly at the end.
- **Check it after a long break**: `-Status` at the start of a resumed session. A watchdog from an earlier request that no longer stands is stopped.

## 7. Taking it back

| What is armed | How to undo it |
|---|---|
| A shutdown that is counting down | `shutdown /a` |
| The watchdog | `watchdog.ps1 -Stop` |

Do all that apply, then tell the user in one line that nothing is armed any more. Check with `watchdog.ps1 -Status`.

## What went wrong before

- The user asked to "turn off the computer after you finished or ran out of usage". The session reached the usage limit in the middle of the work and was cut off; nothing turned the machine off. A last step cannot run in a session that no longer runs: use the watchdog.
- The user later said "continue, no need to shutdown this time". A shutdown that had been scheduled was still counting down and had to be stopped with `shutdown /a`. Undo everything that is armed as soon as the request is taken back.
- A session waiting for the user's approval of a tool call looked "busy" for an hour. The watchdog does not act while that lasts. Do not rely on it to end a session that waits for a permission prompt.

## Additional Resources

- **`scripts/power.ps1`**: the action itself, with the countdown, the notice, the guest check and the dry run.
- **`scripts/watchdog.ps1`**: starts, shows and stops the process that acts when the session stops.
