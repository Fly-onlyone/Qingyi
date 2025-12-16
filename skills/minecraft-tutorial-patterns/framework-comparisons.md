# Framework Comparison Guides

Side-by-side comparisons of Forge/NeoForge vs Fabric approaches for common modding tasks.

## Comparison 1: Item Registration

### Forge/NeoForge Approach

**Philosophy**: Deferred registration during proper lifecycle phase

**Code**:
```java
public class ModItems {
    public static final DeferredRegister<Item> ITEMS =
        DeferredRegister.create(ForgeRegistries.ITEMS, MODID);

    public static final RegistryObject<Item> RUBY = ITEMS.register("ruby",
        () -> new Item(new Item.Properties()));

    public static void register(IEventBus modEventBus) {
        ITEMS.register(modEventBus);
    }
}

// In main mod class:
public MyMod(IEventBus modEventBus) {
    ModItems.register(modEventBus);
}
```

**Pros**:
- ✅ Type-safe `RegistryObject<Item>` references
- ✅ Automatic registry name management
- ✅ Deferred creation prevents initialization order issues
- ✅ Centralized registration point

**Cons**:
- ❌ More boilerplate (DeferredRegister setup)
- ❌ Indirect access via `.get()` method
- ❌ Requires understanding of event buses

---

### Fabric Approach

**Philosophy**: Direct registration during mod initialization

**Code**:
```java
public class ModItems {
    public static final Item RUBY = Registry.register(
        Registries.ITEM,
        new Identifier(MODID, "ruby"),
        new Item(new Item.Settings())
    );

    public static void register() {
        // Items are registered inline above
    }
}

// In ModInitializer:
@Override
public void onInitialize() {
    ModItems.register();
}
```

**Pros**:
- ✅ Simpler, less boilerplate
- ✅ Direct access (no `.get()`)
- ✅ Easier to understand for beginners
- ✅ Immediate registration

**Cons**:
- ❌ Manual `Identifier` creation
- ❌ Must carefully manage initialization order
- ❌ No type-safe reference wrapper

---

### Which Should I Use?

→ **Use the approach for your framework!**

Both achieve the same result - registering an item. The difference is philosophical: Forge prefers deferred, type-safe systems, while Fabric prefers simple, direct approaches.

---

## Comparison 2: Event Handling

### Forge/NeoForge Events

**Philosophy**: Annotation-based event bus system

**Code**:
```java
@Mod.EventBusSubscriber(modid = MODID, bus = Bus.FORGE)
public class MyEvents {
    @SubscribeEvent
    public static void onPlayerJoin(PlayerEvent.PlayerLoggedInEvent event) {
        Player player = event.getEntity();
        player.sendSystemMessage(Component.literal("Welcome!"));
    }

    @SubscribeEvent(priority = EventPriority.HIGH)
    public static void onBlockBreak(BlockEvent.BreakEvent event) {
        if (isProtected(event.getPos())) {
            event.setCanceled(true);
        }
    }
}
```

**Features**:
- Automatic registration via `@Mod.EventBusSubscriber`
- Event priority system (HIGHEST, HIGH, NORMAL, LOW, LOWEST)
- Two event buses: MOD (lifecycle) and FORGE (gameplay)
- Cancelable events with `setCanceled(true)`

---

### Fabric Events

**Philosophy**: Callback-based event system

**Code**:
```java
public class MyEvents {
    public static void register() {
        // Player join
        ServerPlayConnectionEvents.JOIN.register((handler, sender, server) -> {
            ServerPlayerEntity player = handler.getPlayer();
            player.sendMessage(Text.literal("Welcome!"), false);
        });

        // Block break
        PlayerBlockBreakEvents.BEFORE.register((world, player, pos, state, blockEntity) -> {
            if (isProtected(pos)) {
                return false;  // Cancel by returning false
            }
            return true;  // Allow
        });
    }
}

// In ModInitializer:
@Override
public void onInitialize() {
    MyEvents.register();
}
```

**Features**:
- Manual registration required (explicit control)
- Events defined as functional interfaces (lambdas)
- Fabric API provides most events
- Cancel by returning false/ActionResult.FAIL

---

### Key Differences

| Feature | Forge/NeoForge | Fabric |
|---------|---------------|--------|
| Registration | Automatic (@EventBusSubscriber) | Manual (explicit .register()) |
| Syntax | `@SubscribeEvent` methods | Lambda callbacks |
| Priority | Built-in EventPriority | Manual order control |
| Canceling | `event.setCanceled(true)` | Return false or ActionResult.FAIL |
| Custom Events | Post to event bus | Create custom functional interface |

---

## Comparison 3: Data Storage on Entities

### Forge Approach (Pre-1.21: Capabilities)

**Code**:
```java
// Capability interface
public interface IPlayerMana {
    int getMana();
    void setMana(int mana);
    void regenerate();
}

// Capability provider
@Mod.EventBusSubscriber(modid = MODID)
public class PlayerManaProvider {
    @SubscribeEvent
    public static void onAttachCapabilities(AttachCapabilitiesEvent<Entity> event) {
        if (event.getObject() instanceof Player) {
            event.addCapability(new ResourceLocation(MODID, "mana"),
                new PlayerManaCapability());
        }
    }
}

// Usage
player.getCapability(MANA_CAPABILITY).ifPresent(mana -> {
    mana.setMana(100);
});
```

---

### NeoForge Approach (1.21+: Data Attachments)

**Code**:
```java
// Define attachment
public static final AttachmentType<Integer> MANA = AttachmentType.builder()
    .defaultValue(100)
    .serialize(Codec.INT)
    .build();

// Register attachment
@SubscribeEvent
public static void registerAttachments(RegisterAttachmentsEvent event) {
    event.register(MANA);
}

// Usage
int mana = player.getData(MANA);
player.setData(MANA, 150);
```

**Much simpler than Capabilities!**

---

### Fabric Approach (Cardinal Components API)

**Code**:
```java
// Component interface
public interface ManaComponent extends Component {
    int getMana();
    void setMana(int mana);
}

// Register component
CardinalComponentsAPI.ENTITY.registerFor(PlayerEntity.class,
    MY_MANA, player -> new ManaComponentImpl());

// Usage
ManaComponent mana = MY_MANA.get(player);
mana.setMana(100);
```

---

### Comparison Summary

| Approach | Complexity | Type Safety | Serialization |
|----------|------------|-------------|---------------|
| Forge Capabilities | High | Strong | Manual |
| NeoForge Attachments | Low | Strong | Codec-based |
| Fabric CCA | Medium | Strong | Manual |

---

## Comparison 4: Configuration

### Forge/NeoForge Config

**Code**:
```java
public class ModConfig {
    public static final ForgeConfigSpec SPEC;
    public static final ForgeConfigSpec.IntValue MAX_MANA;

    static {
        ForgeConfigSpec.Builder builder = new ForgeConfigSpec.Builder();

        builder.comment("Player mana settings");
        builder.push("mana");

        MAX_MANA = builder
            .comment("Maximum mana a player can have")
            .defineInRange("maxMana", 100, 0, 1000);

        builder.pop();

        SPEC = builder.build();
    }
}

// Register
ModLoadingContext.get().registerConfig(ModConfig.Type.COMMON, ModConfig.SPEC);

// Use
int maxMana = ModConfig.MAX_MANA.get();
```

**Features**:
- Built into Forge/NeoForge
- Type-safe config values
- Automatic GUI generation
- Validation (min/max ranges)
- Comments in config file

---

### Fabric Config (via Cloth Config API)

**Code**:
```java
public class ModConfig {
    @ConfigEntry.Gui.Tooltip
    @ConfigEntry.BoundedDiscrete(min = 0, max = 1000)
    public int maxMana = 100;

    public static ModConfig load() {
        // Use AutoConfig or manual JSON loading
        return AutoConfig.register(ModConfig.class,
            GsonConfigSerializer::new).getConfig();
    }
}

// Use
int maxMana = ModConfig.load().maxMana;
```

**Features**:
- Requires Cloth Config API dependency
- Annotation-based configuration
- GUI provided by Cloth Config
- JSON file format

---

## Comparison 5: Custom GUIs

### Forge/NeoForge GUI

**Code**:
```java
public class CustomScreen extends Screen {
    public CustomScreen() {
        super(Component.literal("Custom GUI"));
    }

    @Override
    protected void init() {
        super.init();

        // Add widgets
        this.addRenderableWidget(Button.builder(
            Component.literal("Click Me"),
            btn -> Minecraft.getInstance().setScreen(null)
        ).bounds(width / 2 - 50, height / 2, 100, 20).build());
    }

    @Override
    public void render(GuiGraphics graphics, int mouseX, int mouseY, float partialTick) {
        this.renderBackground(graphics);
        graphics.drawCenteredString(font, title, width / 2, 20, 0xFFFFFF);
        super.render(graphics, mouseX, mouseY, partialTick);
    }
}

// Open GUI
Minecraft.getInstance().setScreen(new CustomScreen());
```

---

### Fabric GUI

**Code**:
```java
public class CustomScreen extends Screen {
    public CustomScreen() {
        super(Text.literal("Custom GUI"));
    }

    @Override
    protected void init() {
        super.init();

        // Add widgets
        this.addDrawableChild(ButtonWidget.builder(
            Text.literal("Click Me"),
            btn -> client.setScreen(null)
        ).dimensions(width / 2 - 50, height / 2, 100, 20).build());
    }

    @Override
    public void render(DrawContext context, int mouseX, int mouseY, float delta) {
        super.render(context, mouseX, mouseY, delta);
        context.drawCenteredTextWithShadow(textRenderer, title, width / 2, 20, 0xFFFFFF);
    }
}

// Open GUI
MinecraftClient.getInstance().setScreen(new CustomScreen());
```

---

### Key Differences

| Aspect | Forge/NeoForge | Fabric |
|--------|---------------|--------|
| Text Component | `Component` | `Text` |
| Render Context | `GuiGraphics` (1.20+) | `DrawContext` |
| Button Builder | `Button.builder()` | `ButtonWidget.builder()` |
| Access MC Instance | `Minecraft.getInstance()` | `MinecraftClient.getInstance()` |

**Otherwise very similar!**

---

## Comparison 6: Network Packets

### Forge/NeoForge Packets

**Code**:
```java
// Register channel
public static final SimpleChannel CHANNEL = NetworkRegistry.newSimpleChannel(
    new ResourceLocation(MODID, "main"),
    () -> "1.0",
    version -> version.equals("1.0"),
    version -> version.equals("1.0")
);

// Register packet
public static void register() {
    int id = 0;
    CHANNEL.registerMessage(id++, ManaUpdatePacket.class,
        ManaUpdatePacket::encode,
        ManaUpdatePacket::decode,
        ManaUpdatePacket::handle);
}

// Packet class
public class ManaUpdatePacket {
    private final int mana;

    public ManaUpdatePacket(int mana) {
        this.mana = mana;
    }

    public static void encode(ManaUpdatePacket packet, FriendlyByteBuf buf) {
        buf.writeInt(packet.mana);
    }

    public static ManaUpdatePacket decode(FriendlyByteBuf buf) {
        return new ManaUpdatePacket(buf.readInt());
    }

    public static void handle(ManaUpdatePacket packet, Supplier<NetworkEvent.Context> ctx) {
        ctx.get().enqueueWork(() -> {
            // Handle packet on correct thread
        });
        ctx.get().setPacketHandled(true);
    }
}

// Send to client
CHANNEL.send(PacketDistributor.PLAYER.with(() -> player), new ManaUpdatePacket(100));
```

---

### Fabric Packets

**Code**:
```java
// Register receiver
public static final Identifier MANA_UPDATE_ID = new Identifier(MODID, "mana_update");

public static void registerReceivers() {
    ClientPlayNetworking.registerGlobalReceiver(MANA_UPDATE_ID,
        (client, handler, buf, responseSender) -> {
            int mana = buf.readInt();

            // Handle on client thread
            client.execute(() -> {
                // Update mana on client
            });
        });
}

// Send to client
ServerPlayNetworking.send(player, MANA_UPDATE_ID, PacketByteBufs.create().writeInt(100));
```

---

### Comparison Summary

| Feature | Forge/NeoForge | Fabric |
|---------|---------------|--------|
| Channel Setup | SimpleChannel registration | Identifier-based |
| Packet Classes | Separate encode/decode/handle | Lambda handlers |
| Thread Safety | enqueueWork() | client.execute() |
| Complexity | Higher (more boilerplate) | Lower (simpler) |

---

## When to Show Framework Comparisons in Tutorials

**Always show both** when:
- Concept differs significantly between frameworks
- Different APIs or approaches
- Different initialization patterns

**Show only one** when:
- Code is identical or nearly identical
- Explaining framework-agnostic concepts (Java basics, algorithms)
- Advanced topics specific to one framework (Mixins for Fabric)

**Template**:
```markdown
## [Topic Name]

### Forge/NeoForge Approach
[Code and explanation]

**Pros**: [What's good about this approach]
**Cons**: [What's challenging about this approach]

---

### Fabric Approach
[Code and explanation]

**Pros**: [What's good about this approach]
**Cons**: [What's challenging about this approach]

---

### Which Should I Use?
→ Use the approach for your framework! Both achieve the same goal.
```

---

## See Also

- [Main Tutorial Patterns](./SKILL.md)
- [Exercise Templates](./exercise-templates.md)
- [Common Mistakes Database](./common-mistakes.md)
