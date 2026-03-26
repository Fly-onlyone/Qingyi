# False Positive Patterns

Patterns that LOOK like dead code but are dynamically consumed at runtime. Removing
these breaks the application. Always check for these before confirming dead code.

## Framework Registration Patterns

### ORM / Database Models

Models registered or auto-discovered by the framework, not by direct call-site imports.

**Python (Beanie/MongoDB):**
```python
document_models = [User, Order, Strategy]
await init_beanie(database=db, document_models=document_models)  # NOT dead
```

**Python (SQLAlchemy):**
```python
from app.models.user import User  # NOT dead — used by Alembic migrations
```

**Python (Django):**
```python
class MyModel(models.Model): ...  # NOT dead — auto-discovered by Django
```

**TypeScript (Prisma):**
```typescript
// Models defined in schema.prisma are generated — prisma client methods are NOT dead
```

**Java (JPA/Hibernate):**
```java
@Entity  // NOT dead — scanned by JPA entity manager
public class User { ... }
```

**C# (Entity Framework):**
```csharp
public class AppDbContext : DbContext {
    public DbSet<User> Users { get; set; }  // NOT dead — EF convention
}
```

**Go (GORM):**
```go
db.AutoMigrate(&User{})  // NOT dead — registered for migration
```

**Ruby (ActiveRecord):**
```ruby
class User < ApplicationRecord  # NOT dead — auto-discovered by Rails
end
```

### Router / Route Registration

Routers imported and registered via framework API calls:

**Python (FastAPI):**
```python
router.include_router(users.router, prefix="/users")  # NOT dead
```

**Python (Django):**
```python
urlpatterns = [path("api/", include("app.urls"))]  # NOT dead
```

**Node.js (Express):**
```javascript
app.use("/api", require("./routes/api"));  # NOT dead
```

**Go (Gin/Echo/Chi):**
```go
r.GET("/users", handlers.GetUsers)  // NOT dead
```

**Java (Spring Boot):**
```java
@RestController  // NOT dead — auto-scanned by Spring
public class UserController { ... }
```

**C# (ASP.NET):**
```csharp
[ApiController]  // NOT dead — discovered by ASP.NET middleware
public class UsersController : ControllerBase { ... }
```

**Ruby (Rails):**
```ruby
# config/routes.rb
resources :users  # Controllers are NOT dead — convention-based
```

**File-based routing** (Next.js, Nuxt, TanStack Router, SvelteKit, Remix):
Route files in designated directories are auto-discovered. A route file with no
explicit import is NOT dead.

### Middleware / Filter Registration

```python
app.add_middleware(RequestLoggingMiddleware)  # NOT dead
```
```java
@Component  // NOT dead — Spring auto-scans
public class AuthFilter implements Filter { ... }
```
```csharp
app.UseMiddleware<LoggingMiddleware>();  // NOT dead
```
```go
r.Use(middleware.Logger())  // NOT dead
```

### Dependency Injection Bindings

```java
@Service  // NOT dead — injected by Spring DI container
public class UserService { ... }

@Configuration
public class AppConfig {
    @Bean  // NOT dead — registered in DI container
    public DataSource dataSource() { ... }
}
```
```csharp
services.AddScoped<IUserService, UserService>();  // NOT dead
```
```python
# FastAPI Depends()
def get_db(): ...  # NOT dead — used as Depends(get_db)
```

---

## Decorator / Annotation / Attribute Patterns

Functions or classes marked with framework decorators are called by the runtime,
not by direct code references.

### Python Decorators
```python
@tool          # MCP/Agent SDK — called at runtime
@pytest.fixture  # Called by pytest
@app.on_event("startup")  # FastAPI lifecycle
@celery.task   # Celery worker
@click.command()  # CLI command
@lru_cache     # Standard lib — wraps the function
```

### Java/Kotlin Annotations
```java
@Scheduled(fixedRate = 5000)  // NOT dead — called by Spring scheduler
@EventListener  // NOT dead — called by Spring event bus
@PostConstruct  // NOT dead — called after DI
@Test  // NOT dead — called by JUnit
```

### C# Attributes
```csharp
[Fact]  // NOT dead — called by xUnit
[HttpGet]  // NOT dead — ASP.NET route binding
[Obsolete]  // Marks deprecation but does not mean unused
```

### Rust Derive Macros and Attributes
```rust
#[derive(Serialize, Deserialize)]  // NOT dead — used by serde at compile time
#[tokio::main]  // NOT dead — entry point macro
#[test]  // NOT dead — called by cargo test
```

### Go Build Tags and Init
```go
func init() { ... }  // NOT dead — called automatically by Go runtime
//go:generate  // NOT dead — used by go generate
```

---

## Import Patterns That Hide Usage

### Lazy / Conditional Imports
```python
def process_pdf(path):
    import fitz  # Lazy — NOT dead
```
```typescript
const module = await import("heavy-library");  // Dynamic — NOT dead
```
```java
Class.forName("com.example.Driver");  // Reflection — NOT dead
```

### Side-Effect / Blank Imports
```typescript
import "./polyfills";  // Side-effect only — NOT dead
import "reflect-metadata";  // Required for decorators
```
```go
import _ "github.com/lib/pq"  // Blank import for driver registration — NOT dead
```
```python
import app.patches  # Side-effect module — NOT dead
```

### Type-Only Imports
```python
if TYPE_CHECKING:
    from app.models import User  # Used by type checker — NOT dead
```
```typescript
import type { User } from "./models";  // Erased at runtime but used by tsc
```

### Re-exports for Public API
```python
# __init__.py
from .core import Engine  # Consumed via: from package import Engine
```
```rust
// lib.rs
pub use internal::Engine;  // Public API re-export
```

---

## Dependency False Positives

### Type Stub / Declaration Packages

Never directly imported but used by type checkers:

| Package | Provides Types For |
|---------|-------------------|
| `pandas-stubs` | `pandas` |
| `types-requests` | `requests` |
| `@types/node` | Node.js built-ins |
| `@types/react` | `react` |

### Transitive Runtime Dependencies

Required at runtime by other packages without direct import:

| Package | Required By | Why |
|---------|------------|-----|
| `einops` | `sentence-transformers` | Model architecture |
| `tokenizers` | `transformers` | Fast tokenization |
| `python-multipart` | `FastAPI` | Form data parsing |
| `libc` (Rust) | Many Rust crates | FFI binding |

Verify by checking if removing the package breaks `import parent_package` at runtime.

### Peer Dependencies

Required by other packages but not directly imported:
```json
"react": "^19.0.0"  // Peer dep of react-dom, MUI, etc. — NOT dead
```
```xml
<!-- Maven parent/BOM dependencies provide transitive deps -->
<dependency><groupId>org.springframework.boot</groupId>...</dependency>
```

### Build / Dev Tool Dependencies

Used by build tools or scripts, not imported in source:

| Package | Used By |
|---------|---------|
| `@vitejs/plugin-react` | `vite.config.ts` |
| `typescript` | `tsc` CLI |
| `@tauri-apps/cli` | Tauri build toolchain |
| `maven-compiler-plugin` | Maven build |
| `cargo-watch` | Cargo dev workflow |
| `rubocop` | Ruby linter |

Check `scripts` in manifests, `Makefile`, CI configs, and tool config files before removing.

---

## Styling and UI False Positives

### Name Collisions Across Systems

A name may exist in both code and style contexts:
```typescript
// JS animation variant — might be dead
export const glowPulse = (color) => ({ ... });
// CSS keyframe — different system, alive
"@keyframes glowPulse": { ... }
```

Grep results showing the same name does NOT mean the code-level export is alive.
Check if the hit is in an import/usage context vs a style/config context.

### CSS/HTML Class Names

In template-based frameworks (Rails, Django, Blade, JSP), grep may not find a CSS class
used in a template because the class name is in HTML, not in a code import. Check
templates, not just source files.

### Theme Tokens and Design System Variables

Tokens defined in JS/TS theme files may be consumed via CSS custom properties:
```css
--ui-zoom: 1;  /* Consumed in CSS, not via JS import */
```

---

## Entry Points, Lifecycle, and Callbacks

### CLI Entry Points
```toml
[project.scripts]
my-cli = "app.cli:main"  # main() is NOT dead
```
```json
"bin": { "mycli": "./cli.js" }  // NOT dead
```
```rust
fn main() { ... }  // Crate entry point — NOT dead
```

### Lifecycle Hooks / Event Handlers
```python
async def lifespan(app): ...  # FastAPI lifecycle — NOT dead
```
```java
@PostConstruct public void init() { ... }  // NOT dead
@PreDestroy public void cleanup() { ... }  // NOT dead
```
```go
func init() { ... }  // Go init — NOT dead
```

### Callback / Strategy Functions
```python
sentry_sdk.init(traces_sampler=_traces_sampler)  # _traces_sampler is NOT dead
```
```java
executor.submit(myRunnable);  // myRunnable is NOT dead
```
```go
http.HandleFunc("/", handler)  // handler is NOT dead
```

---

## Convention-Based Discovery

Some frameworks discover code by naming convention or directory structure:

| Framework | Convention |
|-----------|-----------|
| Django | `models.py`, `views.py`, `admin.py` auto-discovered per app |
| Rails | `app/models/`, `app/controllers/` auto-loaded |
| Spring Boot | `@Component`-annotated classes in scan packages |
| Next.js / Nuxt | `pages/` or `app/` directory = routes |
| SvelteKit | `src/routes/` directory = routes |
| Pytest | `test_*.py` files and `test_*` functions auto-discovered |
| JUnit | `@Test`-annotated methods auto-discovered |
| Go | `*_test.go` files auto-discovered by `go test` |

---

## Quick Decision Tree

```
Is the symbol...
├── Registered in a framework config/DI container? → NOT dead
├── Decorated/annotated with a framework marker? → NOT dead
├── Imported inside a function body or via reflection? → NOT dead
├── A type stub or declaration package? → NOT dead
├── Required by another installed package (transitive)? → VERIFY at runtime
├── Used in build scripts, Makefile, or CI config? → NOT dead
├── A name matching a CSS/HTML class or keyframe? → Check WHICH system uses it
├── In a convention-based discovery directory? → NOT dead
├── An entry point, lifecycle hook, or callback? → NOT dead
├── A side-effect or blank import? → NOT dead
└── None of the above? → LIKELY dead — verify with grep
```
