# Mixin Documentation Guide

This file provides patterns for documenting Mixin modifications in Minecraft mods (primarily Fabric/Quilt).

## What Are Mixins?

Mixins are a way to modify vanilla Minecraft code at runtime without directly editing the game's files. They are primarily used in Fabric/Quilt mods, though Forge can also use them via MixinExtras.

## Why Document Mixins Carefully?

- **Compatibility Risk**: Mixins can conflict with other mods modifying the same code
- **Version Fragility**: Mixins break when vanilla code changes between Minecraft versions
- **Hard to Debug**: Mixin errors can be cryptic and hard to trace
- **Critical for Maintainers**: Other developers need to understand what's being modified

## Mixin Documentation Structure

### Pattern 1: Class-Level Documentation

```markdown
### Mixin: ExampleMixin

**Target Class**: `net.minecraft.world.entity.player.Player`
**Purpose**: Add custom behavior to player jumping
**Mixin Type**: Method injection (INVOKE)
**Compatibility Risk**: Medium (common modification target)
**Minecraft Versions**: 1.20.x (method signature may change)

**What This Mixin Does**:
- Injects code after the player jumps
- Plays a custom sound effect
- Awards an advancement if player jumps 100 times

**Why Mixin Instead of Event**:
- Fabric doesn't have a player jump event
- Need to run code immediately after jump occurs
- Forge alternative: Would use `LivingEvent.LivingJumpEvent`

**Conflict Risk**:
- High: Many mods modify player jumping (double-jump mods, etc.)
- Mitigation: Using @At(value="INVOKE") with specific target reduces conflicts

**Vanilla Code Modified**:
```java
// In Player.java (vanilla)
public void jumpFromGround() {
    // ... jump logic ...
    this.level.playSound(null, this.getX(), this.getY(), this.getZ(),
                         SoundEvents.PLAYER_JUMP, this.getSoundSource(),
                         1.0F, 1.0F);  // ← We inject AFTER this line
}
```

**Our Injection**:
```java
@Mixin(Player.class)
public class ExampleMixin {
    @Inject(
        method = "jumpFromGround",
        at = @At(
            value = "INVOKE",
            target = "Lnet/minecraft/world/level/Level;playSound" +
                     "(Lnet/minecraft/world/entity/player/Player;" +
                     "DDDLnet/minecraft/sounds/SoundEvent;" +
                     "Lnet/minecraft/sounds/SoundSource;FF)V"
        )
    )
    private void onJump(CallbackInfo ci) {
        Player player = (Player) (Object) this;

        // Play custom sound
        player.level.playSound(null, player.getX(), player.getY(), player.getZ(),
                               ModSounds.CUSTOM_JUMP, player.getSoundSource(),
                               1.0F, 1.0F);

        // Track jump count
        JumpTrackerData.incrementJumps(player);
    }
}
```

**Testing**:
- Join world and jump → Should hear custom sound
- Jump 100 times → Should receive advancement
- Check compatibility with other jump-modifying mods

**Breaking Changes**:
- **1.20 → 1.21**: `playSound` method signature changed (added extra parameter)
- **Fix**: Update target string to match new signature
```

---

## Mixin Types Documentation

### @Inject - Method Injection

**Purpose**: Run custom code before, after, or in the middle of a method

```markdown
### Injection Type: @Inject

**Use Case**: Add behavior without replacing vanilla logic

**Injection Points**:
- `@At("HEAD")` - Beginning of method
- `@At("RETURN")` - Before any return statement
- `@At("TAIL")` - End of method (before implicit return)
- `@At(value="INVOKE", target="...")` - Before/after specific method call

**Example - HEAD Injection**:
```java
/**
 * Injects at the start of the tick method to update custom data.
 * Runs before any vanilla tick logic.
 *
 * @reason We need to update custom player data every tick before vanilla uses it
 * @compatibility HIGH - head injections rarely conflict
 */
@Inject(method = "tick", at = @At("HEAD"))
private void onTickStart(CallbackInfo ci) {
    Player player = (Player) (Object) this;
    CustomPlayerData.update(player);
}
```

**Example - RETURN Injection**:
```java
/**
 * Injects before the method returns to modify the return value.
 *
 * @reason Cancel damage in protected zones
 * @compatibility MEDIUM - other mods may also cancel damage here
 */
@Inject(method = "hurt", at = @At("RETURN"), cancellable = true)
private void onHurt(DamageSource source, float amount, CallbackInfoReturnable<Boolean> cir) {
    Player player = (Player) (Object) this;
    if (ProtectionService.isProtected(player)) {
        cir.setReturnValue(false);  // Cancel damage
    }
}
```
```

### @Redirect - Method Call Redirection

**Purpose**: Replace a method call with custom logic

```markdown
### Redirect Type: @Redirect

**Use Case**: Change the behavior of a specific method call

**Warning**: VERY INVASIVE - High conflict risk

**Example**:
```java
/**
 * Redirects the damage calculation to apply custom modifiers.
 *
 * TARGET: Player.hurt() calls getDamageAfterArmorAbsorb()
 * REPLACES: Vanilla armor calculation with custom formula
 *
 * @risk HIGH - Overwrites vanilla behavior entirely
 * @conflicts Mods that modify armor calculations (most armor mods)
 * @alternative Consider using @ModifyVariable to tweak the result instead
 */
@Redirect(
    method = "hurt",
    at = @At(
        value = "INVOKE",
        target = "Lnet/minecraft/world/entity/player/Player;" +
                 "getDamageAfterArmorAbsorb(Lnet/minecraft/world/damagesource/DamageSource;F)F"
    )
)
private float redirectArmorCalc(Player player, DamageSource source, float damage) {
    // Custom armor calculation
    return CustomArmorCalculator.calculate(player, source, damage);
}
```

**Best Practice**: Use @Redirect sparingly. Prefer @Inject or @ModifyVariable when possible.
```

### @Overwrite - Complete Method Replacement

**Purpose**: Completely replace a vanilla method

```markdown
### Overwrite Type: @Overwrite

**Use Case**: When injection won't work and you need total control

**WARNING**:
- ⚠️ HIGHEST CONFLICT RISK - Only one mod can @Overwrite a method
- ⚠️ Must maintain vanilla behavior you're not changing
- ⚠️ Breaks when vanilla changes the method

**When to Use**:
- Absolutely necessary (no injection points work)
- Method logic is fundamentally broken and needs full replacement
- You're maintaining vanilla behavior for parts you don't modify

**Example**:
```java
/**
 * OVERWRITES the entire dropExperience method to change XP drop logic.
 *
 * REASON: Vanilla method has no injection points and we need to change
 *         the core XP calculation formula, not just modify the value.
 *
 * VANILLA BEHAVIOR PRESERVED:
 * - Still drops XP orbs
 * - Still respects player causing death
 * - Still uses experience value from entity
 *
 * CHANGED BEHAVIOR:
 * - XP amount multiplied by 2x in difficult biomes
 * - XP split into smaller orbs for better performance
 *
 * MAINTENANCE:
 * - ⚠️ Check this method every Minecraft update
 * - ⚠️ Vanilla may add new logic we need to incorporate
 * - ⚠️ Consider switching to injection if vanilla adds injection points
 *
 * CONFLICTS:
 * - ❌ INCOMPATIBLE with any mod that @Overwrites dropExperience
 * - ❌ BREAKS if other mods inject into removed parts of vanilla code
 */
@Overwrite
public void dropExperience() {
    // Full method implementation here
    // Must include ALL vanilla logic you want to keep!
}
```

**Alternatives to @Overwrite**:
1. Try @Inject with different injection points
2. Try @ModifyVariable or @ModifyArg
3. Try @Redirect for specific method calls
4. Use @Overwrite only as last resort
```

---

## Mixin Configuration Documentation

### mixin.json File

```markdown
## Mixin Configuration: mixins.mymod.json

**Location**: `src/main/resources/mixins.mymod.json`

**Configuration**:
```json
{
  "required": true,
  "package": "com.example.mymod.mixin",
  "compatibilityLevel": "JAVA_17",
  "mixins": [
    "ExampleMixin",
    "ServerOnlyMixin"
  ],
  "client": [
    "ClientOnlyMixin",
    "RenderMixin"
  ],
  "injectors": {
    "defaultRequire": 1
  }
}
```

**Configuration Options**:

- **required**: If true, game crashes if mixin fails to apply
  - `true`: Use for critical mixins
  - `false`: Use for optional enhancements

- **package**: Base package for mixin classes

- **compatibilityLevel**: Java version
  - `JAVA_17` for Minecraft 1.18+
  - `JAVA_16` for Minecraft 1.17

- **mixins**: Common mixins (both client and server)

- **client**: Client-only mixins (crash on dedicated server if not separated!)

- **server**: Server-only mixins

- **injectors.defaultRequire**: Minimum number of injections that must succeed
  - `1`: At least one injection point must work
  - `0`: Optional injection (doesn't crash if injection point missing)

**When to Use defaultRequire=0**:
- Mixin targets multiple Minecraft versions with different code
- Injection point may not exist in some versions
- Mixin is optional enhancement, not critical

**Example**:
```json
{
  "mixins": [
    "OptionalFeatureMixin"
  ],
  "injectors": {
    "defaultRequire": 0
  }
}
```
```

---

## Compatibility Documentation

### Documenting Known Conflicts

```markdown
## Mixin Compatibility Matrix

### ExampleMixin (Player Jump Modification)

**Known Compatible Mods**:
- ✅ Fabric API - No conflicts
- ✅ Trinkets - Different injection point
- ✅ Origins - Uses @Redirect on different method

**Known Incompatible Mods**:
- ❌ DoubleJump - Overwrites same method
  - **Workaround**: Disable ExampleMixin in config if DoubleJump is installed
  - **Detection**: Check if DoubleJump is loaded before applying mixin

- ❌ BetterJumping - Uses same injection point with conflicting logic
  - **Workaround**: Load order matters - our mixin should load first
  - **Priority**: Set priority=900 to run before BetterJumping

**Untested Mods** (report issues):
- ❓ Parkour Mod - Unknown compatibility
- ❓ Movement Overhaul - May conflict with jump modifications

**Conflict Resolution**:
```java
// In mixin config
{
  "overwrites": {
    "conformVisibility": true
  },
  "mixins": [
    "ExampleMixin"
  ]
}

// Optional: Conditional mixin application
public class MixinConfigPlugin implements IMixinConfigPlugin {
    @Override
    public boolean shouldApplyMixin(String targetClassName, String mixinClassName) {
        // Don't apply if DoubleJump is loaded
        if (mixinClassName.contains("ExampleMixin")) {
            return !FabricLoader.getInstance().isModLoaded("doublejump");
        }
        return true;
    }
}
```
```

---

## Debugging Mixin Documentation

### Common Mixin Errors

```markdown
## Troubleshooting Guide

### Error: "Mixin target not found"

**Cause**: Target class doesn't exist or changed name

**Solution**:
1. Verify target class exists: `net.minecraft.world.entity.player.Player`
2. Check if vanilla renamed the class (use mappings)
3. Verify `compatibilityLevel` matches Minecraft version

### Error: "Method not found"

**Cause**: Method signature doesn't match

**Solution**:
1. Decompile Minecraft jar to check exact signature
2. Use descriptor format: `methodName(Lcom/example/Type;I)V`
3. Check if method was renamed in this Minecraft version

**Example Debug Process**:
```java
// If this fails:
@Inject(method = "jumpFromGround", at = @At("HEAD"))

// 1. Check method exists in Player class
// 2. Check method name (might be obfuscated)
// 3. Check method signature: public void jumpFromGround()
// 4. Use MixinExtras to print available methods:
//    Add `-Dmixin.debug.export=true` to JVM args
```

### Error: "Injection point not found"

**Cause**: Target method call doesn't exist at expected location

**Solution**:
1. Method body changed in vanilla
2. Method call was removed or moved
3. Use @At("HEAD") or @At("RETURN") instead of specific INVOKE targets

### Error: "Mixin failed to apply"

**Cause**: Another mod already modified the same code incompatibly

**Solution**:
1. Check logs for which mod conflicts
2. Use mixin priority to change load order
3. Consider different injection strategy
4. Make mixin optional (defaultRequire=0)
```

---

## Mixin Documentation Template

```markdown
### Mixin: [MixinClassName]

**Target Class**: `fully.qualified.ClassName`
**Target Methods**: `methodName()`, `otherMethod()`
**Mixin Type**: @Inject / @Redirect / @Overwrite / @ModifyVariable
**Injection Point**: HEAD / RETURN / TAIL / INVOKE:target
**Purpose**: [One sentence description]
**Side**: Common / Client / Server

**What This Changes**:
- Change 1: [Description]
- Change 2: [Description]

**Why Mixin**:
- Reason this approach was chosen over alternatives

**Compatibility**:
- Risk Level: LOW / MEDIUM / HIGH / CRITICAL
- Known Conflicts: [List of mods]
- Known Compatible: [List of mods]

**Vanilla Code Modified**:
```java
// Show relevant vanilla code
```

**Our Modification**:
```java
// Show full mixin code with comments
```

**Maintenance Notes**:
- Minecraft Version: 1.20.x
- Breaking Changes: [What changes in vanilla would break this]
- Alternative Approaches: [Other ways to achieve same goal]

**Testing**:
- Test Case 1: [How to verify it works]
- Test Case 2: [Expected behavior]

**See Also**:
- [Related mixin]
- [Alternative implementation]
```

---

## Best Practices for Mixin Documentation

1. **Always Explain Why**: Document why a mixin was necessary (no event alternative, etc.)
2. **Show Vanilla Context**: Include relevant vanilla code for reference
3. **List Conflicts**: Document known incompatible mods
4. **Version Specific**: Tag documentation with Minecraft version
5. **Maintenance Plan**: Note what vanilla changes would break the mixin
6. **Testing Instructions**: How to verify the mixin works correctly
7. **Alternatives**: Document other approaches that were considered

## Anti-Patterns to Avoid

- ❌ Using @Overwrite without exhaustive documentation
- ❌ Not testing with common mods for conflicts
- ❌ Forgetting to separate client-only mixins
- ❌ Not documenting why injection point was chosen
- ❌ Omitting vanilla code context
- ❌ No version-specific notes

---

## See Also

- [Main Documentation Patterns](./SKILL.md)
- [Registry Documentation Examples](./registry-docs-examples.md)
- [Event Handler Documentation](./event-handler-docs.md)
