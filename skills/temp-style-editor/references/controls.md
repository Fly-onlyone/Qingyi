# Controls

Patterns for the temporary panel. Draw every control with the project's own components so
that it inherits fonts, focus rings and states.

## Stepper: `-` / value / `+`

For numbers: opacity, tint share, size, spacing, radius.

- Pick a fixed step that makes one press visible but not jumpy: 1% for subtle tints, 2% for
  fills, 1 px or one spacing unit for sizes.
- Clamp to a sane range (for example 0–50% for tints).
- **Round to the step after every change**, or repeated presses drift (0.1 + 0.2 ≠ 0.3):

  ```
  next = clamp(round((value + delta) / step) * step, min, max)
  ```

  Simpler still: store whole units (percent, pixels) as integers and convert when
  applying.
- Show the value with fixed precision (`17%`, `12 px`) in a fixed-width cell, so the `+`
  button does not move as the digits change.

## Cycle

For a choice among named options: palette color, font, weight, variant.

- Take the options from the project's palette or design tokens, such as theme colors
  ("Primary", "Link", "Magenta", ...), the type scale or the spacing scale. Every choice is
  then one the design system already supports, and baking it in is one token name.
- One press moves to the next option and wraps round at the end. The button's label is the
  current option.
- Offer a free color picker or a typed hex value only when the user asks for one.

## A/B switch

For comparing the current look with a candidate.

- Name the variants after what they are ("Calm" / "Vivid", "Current" / "Proposed"). Show the
  active name on the switch, in the panel title and in the values block.
- Keep a full value set per variant. The tuning controls edit the active variant only, so
  switching back always shows that variant exactly as tuned.
- If the comparison spans more than the tuned values (another layout, other derived
  colors), branch on the variant in one place in the editor module, not across the
  codebase.

## Reset and hide

- **Reset to shipped:** one button per variant puts every value back to its default.
  Nothing persists, so without it only a restart resets.
- **Hide panel:** a toggle (and a key, where the stack has a keymap) that hides the panel
  without resetting anything. The user judges the look without the panel in the way, and
  Phase 2 compares screenshots with it hidden.

## Readouts

Show every constraint a value can break, live. Color the readout as an error when it fails.

**Text contrast (WCAG 2):**

```
channel(c) = c <= 0.04045 ? c / 12.92 : ((c + 0.055) / 1.055) ^ 2.4   (c in 0..1)
L          = 0.2126 R + 0.7152 G + 0.0722 B                          (each channel converted)
ratio      = (L_lighter + 0.05) / (L_darker + 0.05)
```

- AA requires **4.5:1** for body text.
- It requires **3:1** for large text (at least 24 px, or 18.66 px bold) and for icons and
  other graphics (WCAG 1.4.11).
- Measure the weakest text color the edited surface carries (body, muted, links), not only
  the body color.
- For translucent surfaces, composite the surface over the worst backdrop (pure black and
  pure white) before measuring.

**Other limits:**
- a minimum tap target (44 px or 48 px by platform);
- a maximum line length;
- a minimum font size.

## Layout

- Title the panel "<What it tunes> (<variant>, temporary)".
- Use one group per element (Page, Quote, Heading), each with a fixed-width label column.
- Component libraries impose minimum widths (MUI buttons: 64 px). A row of label, color,
  `-`, value and `+` can overflow a narrow pane and shrink unevenly from row to row. Put the
  variable-width control (the color name) on its own line, with `-`/value/`+` on the line
  below.
- Place the panel where it hides nothing the user is judging: a side pane, a corner or a
  separate window.
- Give each control a keyboard path where the stack allows it.

## Values block

End the panel with every current value, one per line, in a form the user can paste back:

```
variant: Vivid
page.tint   = Primary 20%
quote.fill  = Primary 14%
quote.bar   = Primary
weakest text on page: 6.4:1
```

When comparing, show both variants' values, or the active one plus a note that the other
keeps its own.
