---
description: Example command template showing structure and argument usage
---

# Example Command

This is an example slash command that demonstrates the proper format.

## What This Command Does

When invoked, this command will:

1. Perform action 1
2. Perform action 2
3. Provide results

## Instructions for Claude

Please execute the following steps:

### Step 1: Initial Analysis

Analyze the current state:
- Check condition A
- Verify condition B
- Confirm prerequisite C

### Step 2: Execute Main Task

Perform the primary task:
- Do action 1
- Do action 2
- Do action 3

### Step 3: Verification

Verify the results:
- Check result A
- Confirm result B
- Validate output

### Step 4: Report

Provide a summary:

## Results

**Status**: [Success/Failed]

**Actions Taken**:
- Action 1 description
- Action 2 description

**Output**:
[Relevant output here]

**Next Steps**:
1. Suggested next step 1
2. Suggested next step 2

---

## Using Arguments

If your command accepts arguments, reference them with {0}, {1}, etc:

```markdown
---
description: Create item (usage: /create-item <name> <type>)
---

Create a new item named "{0}" of type "{1}":

1. Generate class file
2. Register in mod registry
3. Create resources

Item name: {0}
Item type: {1}
```

Usage: `/create-item ruby_sword weapon`
- {0} becomes `ruby_sword`
- {1} becomes `weapon`

## Best Practices

1. **Clear description**: Explain what command does
2. **Explicit steps**: Number your instructions
3. **Output format**: Specify how to present results
4. **Error handling**: Handle edge cases
5. **Next steps**: Guide user forward
