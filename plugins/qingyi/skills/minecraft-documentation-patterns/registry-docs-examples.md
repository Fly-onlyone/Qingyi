# Registry Documentation Examples

This file provides real-world examples of registry documentation from actual Minecraft mods.

## Example 1: Item Registration (MusicMod - Forge 1.20.1)

### Music Disc Item Documentation

**MusicMod** implements custom music disc items that play audio files from the mod's resources.

**Registry Class**: `com.example.musicmod.registry.ModItems`

```java
public class ModItems {
    public static final DeferredRegister<Item> ITEMS =
        DeferredRegister.create(ForgeRegistries.ITEMS, MusicMod.MODID);

    // Music Disc: TheFatRat - The Storm
    public static final RegistryObject<Item> MUSIC_DISC_THEFATRAT = ITEMS.register(
        "music_disc_thefatrat",
        () -> new RecordItem(
            15,  // Comparator output
            ModSounds.MUSIC_THEFATRAT,
            new Item.Properties()
                .stacksTo(1)
                .rarity(Rarity.RARE),
            4200  // Length in ticks (3:30 = 210 seconds = 4200 ticks)
        )
    );

    public static void register(IEventBus modEventBus) {
        ITEMS.register(modEventBus);
    }
}
```

**Key Features**:
- **Registry Name**: `music_disc_thefatrat` (must match resource files)
- **Comparator Output**: 15 (used in redstone contraptions)
- **Stack Size**: 1 (music discs don't stack)
- **Rarity**: RARE (purple name color in-game)
- **Length**: 4200 ticks (210 seconds)

**Required Resource Files**:
- `assets/musicmod/models/item/music_disc_thefatrat.json` - Item model
- `assets/musicmod/textures/item/music_disc_thefatrat.png` - Texture
- `assets/musicmod/sounds/music_thefatrat.ogg` - Audio file
- `assets/musicmod/sounds.json` - Sound definition

**Usage**:
```java
// Give player the music disc
player.addItem(new ItemStack(ModItems.MUSIC_DISC_THEFATRAT.get()));

// Check if item is this music disc
if (stack.is(ModItems.MUSIC_DISC_THEFATRAT.get())) {
    // Handle music disc logic
}
```

---

## Example 2: Entity Registration (Apocalypse_TNT - NeoForge 1.21.3)

### Custom TNT Entity Documentation

**Apocalypse_TNT** implements spawning TNT entities during an apocalypse event.

**Registry Class**: `com.example.apocalypse.registry.ModEntities`

```java
public class ModEntities {
    public static final DeferredRegister<EntityType<?>> ENTITIES =
        DeferredRegister.create(Registries.ENTITY_TYPE, ApocalypseMod.MODID);

    // Custom TNT entity (uses vanilla PrimedTnt but registered for tracking)
    public static final RegistryObject<EntityType<PrimedTnt>> APOCALYPSE_TNT = ENTITIES.register(
        "apocalypse_tnt",
        () -> EntityType.Builder.<PrimedTnt>of(PrimedTnt::new, MobCategory.MISC)
            .sized(0.98F, 0.98F)  // Hitbox size
            .fireImmune()
            .build("apocalypse_tnt")
    );

    public static void register(IEventBus modEventBus) {
        ENTITIES.register(modEventBus);
    }
}
```

**Spawning Logic**:
```java
// Spawn TNT at random position during apocalypse
public void spawnApocalypseTNT(ServerLevel level, Vec3 position) {
    PrimedTnt tnt = new PrimedTnt(
        ModEntities.APOCALYPSE_TNT.get(),
        level
    );
    tnt.setPos(position);
    tnt.setFuse(80);  // 4 seconds (80 ticks)
    level.addFreshEntity(tnt);
}
```

**Properties**:
- **Entity Type**: PrimedTnt (vanilla TNT behavior)
- **Category**: MISC (miscellaneous entity)
- **Size**: 0.98F × 0.98F (standard TNT hitbox)
- **Fire Immune**: true (won't burn up)
- **Default Fuse**: 80 ticks (4 seconds)

**Event Integration**:
```java
@SubscribeEvent
public static void onEntitySpawn(EntityJoinLevelEvent event) {
    if (event.getEntity() instanceof PrimedTnt tnt) {
        if (tnt.getType() == ModEntities.APOCALYPSE_TNT.get()) {
            // Special apocalypse TNT behavior
            tnt.setFuse(40);  // Shorter fuse for apocalypse TNT
        }
    }
}
```

---

## Example 3: Block Registration with BlockEntity

### Block with Custom Data Storage

**Pattern**: Block + BlockEntity for persistent data

**Registry Classes**:
```java
public class ModBlocks {
    public static final DeferredRegister<Block> BLOCKS =
        DeferredRegister.create(ForgeRegistries.BLOCKS, MODID);

    public static final RegistryObject<Block> CUSTOM_MACHINE = BLOCKS.register(
        "custom_machine",
        () -> new CustomMachineBlock(BlockBehaviour.Properties.of()
            .strength(3.5F)
            .requiresCorrectToolForDrops()
            .sound(SoundType.METAL))
    );

    public static void register(IEventBus modEventBus) {
        BLOCKS.register(modEventBus);
    }
}

public class ModBlockEntities {
    public static final DeferredRegister<BlockEntityType<?>> BLOCK_ENTITIES =
        DeferredRegister.create(ForgeRegistries.BLOCK_ENTITY_TYPES, MODID);

    public static final RegistryObject<BlockEntityType<CustomMachineBlockEntity>> CUSTOM_MACHINE =
        BLOCK_ENTITIES.register(
            "custom_machine",
            () -> BlockEntityType.Builder.of(
                CustomMachineBlockEntity::new,
                ModBlocks.CUSTOM_MACHINE.get()
            ).build(null)
        );

    public static void register(IEventBus modEventBus) {
        BLOCK_ENTITIES.register(modEventBus);
    }
}
```

**BlockEntity Implementation**:
```java
public class CustomMachineBlockEntity extends BlockEntity {
    private int progress = 0;
    private ItemStack inputItem = ItemStack.EMPTY;

    public CustomMachineBlockEntity(BlockPos pos, BlockState state) {
        super(ModBlockEntities.CUSTOM_MACHINE.get(), pos, state);
    }

    @Override
    public void load(CompoundTag tag) {
        super.load(tag);
        progress = tag.getInt("Progress");
        inputItem = ItemStack.of(tag.getCompound("InputItem"));
    }

    @Override
    protected void saveAdditional(CompoundTag tag) {
        super.saveAdditional(tag);
        tag.putInt("Progress", progress);
        tag.put("InputItem", inputItem.save(new CompoundTag()));
    }
}
```

**Documentation Notes**:
- Block and BlockEntity share registry name: `"custom_machine"`
- BlockEntity type references the block in its builder
- Data persistence handled via `load()` and `saveAdditional()`
- NBT structure documented for save format compatibility

---

## Example 4: Creative Tab Organization

### Custom Creative Tab with Multiple Items

**Forge 1.20.1+ Pattern**:
```java
public class ModCreativeTabs {
    public static final DeferredRegister<CreativeModeTab> TABS =
        DeferredRegister.create(Registries.CREATIVE_MODE_TAB, MODID);

    public static final RegistryObject<CreativeModeTab> MUSIC_TAB = TABS.register(
        "music_tab",
        () -> CreativeModeTab.builder()
            .title(Component.translatable("itemGroup.musicmod.music_tab"))
            .icon(() -> new ItemStack(ModItems.MUSIC_DISC_THEFATRAT.get()))
            .displayItems((parameters, output) -> {
                // Add all music disc items
                output.accept(ModItems.MUSIC_DISC_THEFATRAT.get());
                output.accept(ModItems.MUSIC_DISC_NCS.get());
                output.accept(ModItems.MUSIC_DISC_ELECTRO.get());
            })
            .build()
    );

    public static void register(IEventBus modEventBus) {
        TABS.register(modEventBus);
    }
}
```

**Required Language Keys**:
```json
{
  "itemGroup.musicmod.music_tab": "Music Discs"
}
```

**Documentation Notes**:
- Creative tab uses translatable component for internationalization
- Icon is an ItemStack (typically the mod's signature item)
- displayItems() populates the tab contents
- Order matters - items appear in the order they're added

---

## Example 5: Sound Registration

### Custom Sound Events

**Sound Registry**:
```java
public class ModSounds {
    public static final DeferredRegister<SoundEvent> SOUNDS =
        DeferredRegister.create(ForgeRegistries.SOUND_EVENTS, MODID);

    public static final RegistryObject<SoundEvent> MUSIC_THEFATRAT = SOUNDS.register(
        "music_thefatrat",
        () -> SoundEvent.createVariableRangeEvent(
            new ResourceLocation(MODID, "music_thefatrat")
        )
    );

    public static void register(IEventBus modEventBus) {
        SOUNDS.register(modEventBus);
    }
}
```

**sounds.json**:
```json
{
  "music_thefatrat": {
    "sounds": [
      {
        "name": "musicmod:music_thefatrat",
        "stream": true
      }
    ]
  }
}
```

**File Structure**:
```
assets/musicmod/
└── sounds/
    └── music_thefatrat.ogg  (must match name in sounds.json)
```

**Documentation Notes**:
- Registry name: `music_thefatrat`
- Sound file: `music_thefatrat.ogg` (must be OGG format)
- `stream: true` is critical for music (loads incrementally, not all at once)
- Variable range event allows distance-based volume falloff

**Usage in Code**:
```java
// Play sound at player position
level.playSound(
    null,
    player.blockPosition(),
    ModSounds.MUSIC_THEFATRAT.get(),
    SoundSource.RECORDS,
    1.0F,  // Volume
    1.0F   // Pitch
);
```

---

## Registry Name Best Practices

### Naming Conventions

**Good Registry Names**:
- `ruby` (simple, descriptive)
- `ruby_sword` (compound with underscore)
- `music_disc_thefatrat` (clear hierarchy: type_category_specific)
- `apocalypse_tnt` (prefix with mod theme)

**Bad Registry Names**:
- `item1` (not descriptive)
- `RubySword` (should use snake_case, not PascalCase)
- `ruby-sword` (use underscore, not hyphen)
- `the_best_sword_ever` (too casual, not professional)

### Resource File Matching

Registry names MUST match resource file names exactly:

**If registry name is `ruby_sword`**, then:
- Model: `assets/modid/models/item/ruby_sword.json`
- Texture: `assets/modid/textures/item/ruby_sword.png`
- Translation: `item.modid.ruby_sword`

**Mismatch = Purple/Black checkboard texture in-game!**

---

## Documentation Template for Registry Entries

Use this template when documenting registry entries:

```markdown
### [Registry Name]

**Type**: Item / Block / Entity / Sound / etc.
**Class**: FullyQualifiedClassName
**Registry Name**: `registry_name`
**Mod ID**: `modid`

**Properties**:
- Property 1: Value
- Property 2: Value

**Required Resources**:
- File 1: Path and purpose
- File 2: Path and purpose

**Usage Example**:
```java
// Code showing how to use this registered object
```

**Integration Points**:
- Where other mods can interact with this
- Events that are fired
- Configuration options

**Notes**:
- Special behavior or quirks
- Version-specific information
```

---

## See Also

- [Main Documentation Patterns](./SKILL.md)
- [Event Handler Documentation](./event-handler-docs.md)
- [Mixin Documentation Guide](./mixin-documentation.md)
