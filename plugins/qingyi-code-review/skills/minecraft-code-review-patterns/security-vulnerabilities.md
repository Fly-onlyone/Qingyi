# Security Vulnerabilities Database for Minecraft Mods

Common security vulnerabilities in Minecraft mods and their exploits.

## Vulnerability 1: Server Crash (DoS)

**Attack Vector**: Force dedicated server to load client-only classes

**Exploit**:
```java
// Vulnerable code in common package
import net.minecraft.client.Minecraft;

public void onEvent(SomeEvent event) {
    Minecraft.getInstance().player.sendMessage(...);  // ← Loads client class on server
}
```

**Result**: `NoClassDefFoundError` → Server crash

**Mitigation**:
- Move to client package with @OnlyIn(Dist.CLIENT)
- Use DistExecutor for conditional client/server code
- Test on dedicated server before release

---

## Vulnerability 2: Item Duplication via NBT Tampering

**Attack Vector**: Modify item NBT using external editors (NBTExplorer)

**Exploit**:
```java
// Vulnerable: Trust client-provided NBT
public void useItem(ItemStack stack) {
    int charges = stack.getOrCreateTag().getInt("charges");
    // Attacker sets charges=999999 using NBT editor
}
```

**Result**: Infinite item uses, game balance broken

**Mitigation**:
- Server-side validation of NBT values
- Cap values on read: `Math.min(charges, MAX_CHARGES)`
- Cryptographic signatures for critical NBT (advanced)

---

## Vulnerability 3: Registry Name Change → Item Duplication

**Attack Vector**: Change registry name between versions

**Scenario**:
1. Version 1.0: Item registered as `"old_name"`
2. Player has 64 items in inventory
3. Version 1.1: Item registered as `"new_name"` (renamed)
4. Player's items turn to AIR (missing mapping)
5. Player can get 64 new items via creative/crafting
6. Load Version 1.0 again → Original 64 items return
7. **Result**: 128 items total (duplicated)

**Mitigation**:
```java
@SubscribeEvent
public static void onMissingMappings(MissingMappingsEvent event) {
    event.getMappings(ForgeRegistries.ITEMS, MODID).forEach(mapping -> {
        if (mapping.getKey().equals(new ResourceLocation(MODID, "old_name"))) {
            mapping.remap(ModItems.NEW_ITEM.get());  // ← Preserve items
        }
    });
}
```

---

## Vulnerability 4: Privilege Escalation via Client-Side Checks

**Attack Vector**: Modified client bypasses permissions

**Exploit**:
```java
// ❌ Vulnerable: Client-side permission check
public void onClientCommand() {
    if (isAdmin()) {  // ← Runs on client, can be modified
        executeAdminCommand();
    }
}
```

**Result**: Attacker modifies client to always return `isAdmin() = true`

**Mitigation**:
```java
// ✅ Secure: Server-side permission check
@SubscribeEvent
public static void onCommandExecute(CommandEvent event) {
    if (!event.getLevel().isClientSide) {  // ← Server-side
        if (hasPermission(event.getPlayer(), "admin")) {
            // Execute command
        }
    }
}
```

---

## Vulnerability 5: Unbounded NBT Growth → Save Corruption

**Attack Vector**: Repeatedly add to NBT list without limit

**Exploit**:
```java
// Vulnerable: No size limit
public void addEntry(ItemStack stack, String entry) {
    ListTag list = stack.getOrCreateTag().getList("history", Tag.TAG_STRING);
    list.add(StringTag.valueOf(entry));  // ← Attacker adds 1 million entries
    stack.getOrCreateTag().put("history", list);
}
```

**Result**: Save file becomes gigabytes, world won't load

**Mitigation**:
```java
// ✅ Fixed: Size limit enforced
public void addEntry(ItemStack stack, String entry) {
    ListTag list = stack.getOrCreateTag().getList("history", Tag.TAG_STRING);
    if (list.size() < 100) {  // ← Maximum 100 entries
        list.add(StringTag.valueOf(entry));
    } else {
        list.remove(0);  // Remove oldest
        list.add(StringTag.valueOf(entry));
    }
    stack.getOrCreateTag().put("history", list);
}
```

---

## Vulnerability 6: Packet Injection

**Attack Vector**: Modified client sends malicious packets

**Exploit**:
```java
// Vulnerable: No validation of packet data
public void handlePacket(MyPacket packet) {
    int value = packet.getValue();
    player.setHealth(value);  // ← Attacker sends value=999999
}
```

**Mitigation**:
```java
// ✅ Fixed: Validate and cap
public void handlePacket(MyPacket packet) {
    int value = Math.max(1, Math.min(packet.getValue(), 20));  // ← Cap to 1-20
    player.setHealth(value);
}
```

---

## Vulnerability 7: Command Injection via Chat

**Attack Vector**: Execute arbitrary commands via chat input

**Exploit**:
```java
// ❌ Vulnerable: No sanitization
public void onChatMessage(String message) {
    String command = "say " + message;
    server.executeCommand(command);  // ← Attacker sends: "; op hacker"
    // Result: "say ; op hacker" executes two commands!
}
```

**Mitigation**:
- Don't construct commands from user input
- Use proper command API with arguments
- Validate and sanitize all inputs

---

## Vulnerability 8: Race Condition in Multiplayer

**Attack Vector**: Exploit timing between client and server

**Exploit**:
```java
// Vulnerable: Check-then-act race condition
if (player.getMana() >= 10) {  // ← Check
    // Attacker sends two packets simultaneously
    player.setMana(player.getMana() - 10);  // ← Act (not atomic)
    castSpell();
}
// Both packets pass the check before mana is deducted!
```

**Mitigation**:
```java
// ✅ Fixed: Atomic operation
synchronized(player) {
    if (player.getMana() >= 10) {
        player.setMana(player.getMana() - 10);
        castSpell();
    }
}
```

---

## Vulnerability 9: Information Disclosure

**Attack Vector**: Leak sensitive server information to clients

**Exploit**:
```java
// ❌ Vulnerable: Send full player list
public void syncData(Player player) {
    packet.write(allPlayerPasswords);  // ← Leaks passwords!
    sendToClient(player, packet);
}
```

**Mitigation**:
- Only send data the client needs to know
- Never send passwords, API keys, admin lists
- Filter sensitive information before packets

---

## Vulnerability 10: Denial of Service via Particle Spam

**Attack Vector**: Client requests excessive particle spawning

**Exploit**:
```java
// Vulnerable: No rate limiting
@SubscribeEvent
public void onPacket(ParticleRequestPacket packet) {
    for (int i = 0; i < packet.getCount(); i++) {  // ← Attacker sends count=999999
        level.addParticle(...);
    }
}
```

**Result**: Server/client FPS drops to 0, unplayable

**Mitigation**:
```java
// ✅ Fixed: Rate limiting
@SubscribeEvent
public void onPacket(ParticleRequestPacket packet) {
    int count = Math.min(packet.getCount(), 10);  // ← Cap to 10 particles
    for (int i = 0; i < count; i++) {
        level.addParticle(...);
    }
}
```

---

## Security Best Practices Summary

1. **Never Trust Client Data**: Validate all packets and inputs
2. **Server-Side Authority**: All permission checks on server
3. **Bounded Resources**: Limit NBT sizes, particle counts, etc.
4. **Test on Dedicated Server**: Catch client/server violations
5. **Use Server-Side Storage**: Don't store sensitive data in NBT
6. **Atomic Operations**: Prevent race conditions
7. **Rate Limiting**: Prevent spam attacks
8. **Input Sanitization**: Validate all user input
9. **Version Migrations**: Use MissingMappingsEvent for renames
10. **Security Audits**: Regular code reviews

---

## See Also

- [Main Code Review Patterns](./SKILL.md)
- [Performance Anti-Patterns](./performance-antipatterns.md)
