# Exercise Templates for Minecraft Mod Tutorials

This file provides reusable exercise patterns for hands-on learning.

## Exercise Type 1: Fill-in-the-Blank

**Purpose**: Reinforce syntax, structure, and vocabulary

**Difficulty**: Beginner to Intermediate

**Pattern**:
```markdown
## Exercise: [Title]

Fill in the blanks to complete the code:

```java
[Code with _____1_____, _____2_____ blanks]
```

**Hints**:
1. Blank 1: [Type of value expected]
2. Blank 2: [Context clue]

**Answers**:
1. `answer1`
2. `answer2`

**Learning Check**: [Key concept to verify understanding]
```

**Example - Item Registration**:
```markdown
## Exercise: Register a Custom Sword

Fill in the blanks to register a sword with 1000 durability:

```java
public class ModItems {
    public static final DeferredRegister<Item> ITEMS =
        DeferredRegister.create(_____1_____, _____2_____);

    public static final RegistryObject<Item> RUBY_SWORD = ITEMS.register(
        "_____3_____",
        () -> new _____4_____(
            Tiers.DIAMOND,  // Tier
            3,  // Attack damage bonus
            -2.4F,  // Attack speed modifier
            new Item.Properties()
                .durability(_____5_____)
        )
    );
}
```

**Hints**:
1. What registry are we registering to? (See ForgeRegistries)
2. Your mod ID constant
3. Registry name for this sword (lowercase, snake_case)
4. What class extends Item and represents a sword?
5. How many uses should the sword have?

**Answers**:
1. `ForgeRegistries.ITEMS`
2. `MODID` (or your actual mod ID constant)
3. `"ruby_sword"` (must match resource file names)
4. `SwordItem`
5. `1000` (or any positive integer)

**Learning Check**: Registry names must be lowercase with underscores. Does your answer follow this rule?
```

---

## Exercise Type 2: Debug the Code

**Purpose**: Identify and fix common mistakes

**Difficulty**: Intermediate

**Pattern**:
```markdown
## Exercise: Find and Fix the Bugs

The following code has [X] bugs. Can you find and fix them all?

```java
[Code with intentional mistakes]
```

**Bugs to Find**: [Hints about types of bugs]

**Solution**:
[Corrected code with explanations]

**What You Should Have Learned**:
- Mistake pattern 1
- Mistake pattern 2
```

**Example - Event Handler Bugs**:
```markdown
## Exercise: Fix the Broken Event Handler

This event handler has 3 bugs that prevent it from working correctly:

```java
@SubscribeEvent
public void onPlayerJoin(PlayerEvent.PlayerLoggedInEvent event) {
    Player player = event.getEntity();

    // Bug 1: Client-side code in common event
    Minecraft.getInstance().player.sendMessage(
        Component.literal("Welcome!")
    );

    // Bug 2: Wrong variable name
    PlayerDataService.loadData(event.getPlayer());

    // Bug 3: Not checking if server
    player.setHealth(20.0F);
}
```

**Hints**:
1. What happens if this runs on a dedicated server?
2. Look carefully at the variable names
3. Should health manipulation run on client or server?

**Solution**:
```java
@SubscribeEvent
public static void onPlayerJoin(PlayerEvent.PlayerLoggedInEvent event) {  // ← FIX: Added 'static'
    Player player = event.getEntity();

    // FIX #1: Check if server before running server logic
    if (!player.level().isClientSide) {
        // FIX #2: Use 'player' not 'event.getPlayer()' (consistent naming)
        PlayerDataService.loadData(player);

        // FIX #3: Health manipulation on server only
        player.setHealth(20.0F);

        // Send message safely (server can send to player)
        player.sendSystemMessage(Component.literal("Welcome!"));
    }
}
```

**What You Should Have Learned**:
- Event handlers should be static (or manually registered)
- Client/server separation is critical (Minecraft.getInstance() crashes dedicated servers)
- Health and data operations belong on the server
- Consistent variable naming prevents confusion
```

---

## Exercise Type 3: Extend the Feature

**Purpose**: Apply learned concepts to build something new

**Difficulty**: Intermediate to Advanced

**Pattern**:
```markdown
## Exercise: Extend [Feature Name]

You've learned how to [base feature]. Now extend it to:
- Add feature 1
- Add feature 2
- Add feature 3

**Requirements**:
1. Requirement with specific criteria
2. Requirement with specific criteria

**Starter Code**:
[Provide base implementation]

**Hints**:
[Helpful guidance without giving away solution]

**Bonus Challenges**:
- Extra credit challenge 1
- Extra credit challenge 2

**Solution Approach** (not full code):
[High-level steps to solve]

**Example Solution**:
[One possible implementation]
```

**Example - Extend NBT Storage**:
```markdown
## Exercise: Create an Experience Sword

You've learned how to store data on ItemStack using NBT. Create a sword that:
- Gains experience points when killing entities
- Levels up after reaching XP thresholds
- Displays current level in the tooltip
- Gets stronger at each level (bonus attack damage)

**Requirements**:
1. Store XP and level in NBT
2. Award 10 XP per entity kill
3. Level up at 100, 200, 300, etc. XP (level * 100)
4. Each level adds +1 attack damage
5. Tooltip shows: "Level X | XP: Y/Z"

**Starter Code**:
```java
public class ExperienceSwordItem extends SwordItem {
    public ExperienceSwordItem(Tier tier, int attackDamage, float attackSpeed, Properties properties) {
        super(tier, attackDamage, attackSpeed, properties);
    }

    // TODO: Override hurt() or use LivingDeathEvent to award XP
    // TODO: Add methods to get/set XP and level
    // TODO: Override appendHoverText() for tooltip
    // TODO: Override getAttackDamage() to scale with level
}
```

**Hints**:
- Use `stack.getOrCreateTag().putInt("XP", value)` to store XP
- Calculate level from XP: `level = xp / 100` (integer division)
- Listen to `LivingDeathEvent` to detect kills
- Check if killing blow was from this sword: `source.getDirectEntity() instanceof Player player`
- Base attack damage + level bonus: `baseAttack + getLevel(stack)`

**Bonus Challenges**:
1. Add particle effects when leveling up
2. Play sound effect on level up
3. Create config for XP per kill and XP per level
4. Add max level cap (e.g., level 10)
5. Make XP bar appear above hotbar

**Solution Approach**:

**Step 1: NBT Methods**
```java
public static int getXP(ItemStack stack) {
    return stack.getOrCreateTag().getInt("XP");
}

public static void addXP(ItemStack stack, int amount) {
    int current = getXP(stack);
    int level = getLevel(stack);
    int newXP = current + amount;

    stack.getOrCreateTag().putInt("XP", newXP);

    // Check for level up
    int newLevel = newXP / 100;
    if (newLevel > level) {
        // Level up logic (particles, sound)
    }
}

public static int getLevel(ItemStack stack) {
    return getXP(stack) / 100;
}
```

**Step 2: Event Handler**
```java
@SubscribeEvent
public static void onEntityDeath(LivingDeathEvent event) {
    if (event.getSource().getDirectEntity() instanceof Player player) {
        ItemStack weapon = player.getMainHandItem();
        if (weapon.getItem() instanceof ExperienceSwordItem) {
            ExperienceSwordItem.addXP(weapon, 10);
        }
    }
}
```

**Step 3: Tooltip**
```java
@Override
public void appendHoverText(ItemStack stack, Level level, List<Component> tooltip, TooltipFlag flag) {
    int xp = getXP(stack);
    int currentLevel = getLevel(stack);
    int xpForNextLevel = (currentLevel + 1) * 100;

    tooltip.add(Component.literal("Level " + currentLevel)
        .withStyle(ChatFormatting.GOLD));
    tooltip.add(Component.literal("XP: " + xp + "/" + xpForNextLevel)
        .withStyle(ChatFormatting.GRAY));
}
```

**Step 4: Scaled Damage**
```java
@Override
public float getDamageBonus() {
    // This is tricky - need ItemStack context
    // Better approach: Use LivingHurtEvent to modify damage
}

// In event handler:
@SubscribeEvent
public static void onLivingHurt(LivingHurtEvent event) {
    if (event.getSource().getDirectEntity() instanceof Player player) {
        ItemStack weapon = player.getMainHandItem();
        if (weapon.getItem() instanceof ExperienceSwordItem) {
            int level = ExperienceSwordItem.getLevel(weapon);
            event.setAmount(event.getAmount() + level);  // +1 damage per level
        }
    }
}
```

**Example Full Solution**: [Link to complete working implementation]
```

---

## Exercise Type 4: Build from Scratch

**Purpose**: Apply all learned concepts independently

**Difficulty**: Advanced

**Pattern**:
```markdown
## Exercise: Build [Complete Feature]

Using what you've learned, build a complete feature from scratch:

**Feature Description**: [Detailed requirements]

**Must Include**:
- Component 1 with specific behavior
- Component 2 with specific behavior
- Component 3 with specific behavior

**Technical Requirements**:
1. Registry requirement
2. Resource file requirement
3. Event handling requirement
4. Data persistence requirement

**Suggested Architecture**:
```
[ASCII diagram of component relationships]
```

**Testing Checklist**:
- [ ] Test case 1
- [ ] Test case 2
- [ ] Test case 3

**No Starter Code Provided** - Build it yourself!

**Hints**:
[Only high-level guidance, no code]

**Reference Materials**:
- [Link to relevant documentation]
- [Link to similar example]

**Share Your Solution**:
[Instructions for submitting or discussing solutions]
```

**Example - Build a Magic System**:
```markdown
## Exercise: Build a Complete Mana System

Create a magic system for your mod with mana, spells, and regeneration.

**Feature Description**:
Players have a mana bar that regenerates over time. They can cast spells by right-clicking with a wand, which consumes mana. Different wands have different spells.

**Must Include**:
1. **Mana Storage**: Attach mana data to players (capability/component or SavedData)
2. **Wands**: At least 2 wands with different spells
3. **Mana Regeneration**: Restore 1 mana per second (tick handler)
4. **HUD Display**: Show mana bar above hotbar
5. **Particles**: Visual effect when casting spell

**Technical Requirements**:
1. **Registry**: Register wand items
2. **Resources**: Item models, textures, particle textures
3. **Events**: Right-click to cast, tick event for regeneration
4. **Data Persistence**: Mana survives logout/login
5. **Client/Server Sync**: Mana value synced between client and server
6. **Rendering**: Client-only HUD overlay

**Suggested Architecture**:
```
PlayerManaData (stores mana, max mana)
    ↓
ManaService (manages all players' mana)
    ↓
WandItem (consumes mana, casts spell)
    ↓
SpellEffect (particles, damage, etc.)
    ↓
ManaHUD (renders mana bar on client)
```

**Testing Checklist**:
- [ ] Mana bar appears in-game
- [ ] Right-click wand consumes mana and casts spell
- [ ] Mana regenerates over time
- [ ] Mana persists after logout/login
- [ ] Works on dedicated server (no crashes)
- [ ] Spell particles only visible on client

**No Starter Code - Build It Yourself!**

**Hints**:
1. Store mana data using Forge Capability (pre-1.21) or Data Attachment (1.21+)
2. For Fabric, use Cardinal Components API or custom SavedData
3. Sync mana to client using custom packet
4. Use ClientTickEvent for mana regeneration tick
5. Render HUD in RenderGuiOverlayEvent.Post (Forge) or HudRenderCallback (Fabric)
6. Spawn particles with level.addParticle() on client side

**Reference Materials**:
- [Data Persistence Tutorial](link)
- [Network Packet Tutorial](link)
- [HUD Rendering Tutorial](link)

**Share Your Solution**:
Post your implementation to the modding Discord for feedback!
```

---

## Exercise Type 5: Refactor the Code

**Purpose**: Improve code quality and architecture

**Difficulty**: Advanced

**Pattern**:
```markdown
## Exercise: Refactor This Code

The following code works, but has several architectural problems. Refactor it to:
- Follow best practices
- Improve maintainability
- Reduce code smells

**Original Code**:
[Poorly structured but functional code]

**Problems to Address**:
1. Problem 1 (e.g., God Class)
2. Problem 2 (e.g., Magic Numbers)
3. Problem 3 (e.g., Code Duplication)

**Refactoring Goals**:
- Goal 1 (e.g., Extract service layer)
- Goal 2 (e.g., Use constants)
- Goal 3 (e.g., Apply DRY principle)

**Solution Approach**:
[Show before/after architecture]

**Refactored Code**:
[Improved implementation]
```

---

## Exercise Difficulty Guidelines

**Beginner Exercises**:
- Fill-in-the-blank with clear hints
- Single concept focus (just registration, just NBT)
- Starter code provided
- Step-by-step solution available

**Intermediate Exercises**:
- Debug the code (2-3 bugs)
- Extend existing feature (add 1-2 new behaviors)
- Partial starter code
- Solution approach provided (not full code)

**Advanced Exercises**:
- Build from scratch (complete feature)
- Refactor existing code
- Minimal starter code or none
- Hints only, no solution (encourage experimentation)

**Expert Exercises**:
- Architectural challenges
- Performance optimization problems
- Multi-system integration
- No hints, just requirements

---

## Exercise Assessment Rubric

### For Tutorial Authors

Use this rubric to ensure exercises are effective:

**Clarity** (1-5):
- [ ] Instructions are unambiguous
- [ ] Expected outcome is clear
- [ ] Prerequisites are stated

**Relevance** (1-5):
- [ ] Directly reinforces tutorial concepts
- [ ] Matches stated difficulty level
- [ ] Prepares for next learning steps

**Completeness** (1-5):
- [ ] Starter code provided (if appropriate)
- [ ] Hints guide without giving away solution
- [ ] Solution or solution approach included
- [ ] Testing steps defined

**Engagement** (1-5):
- [ ] Interesting/fun to solve
- [ ] Challenging but achievable
- [ ] Real-world applicability
- [ ] Bonus challenges for advanced learners

---

## See Also

- [Main Tutorial Patterns](./SKILL.md)
- [Common Mistakes Database](./common-mistakes.md)
- [Framework Comparison Guides](./framework-comparisons.md)
