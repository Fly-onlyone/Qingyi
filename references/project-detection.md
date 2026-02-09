# Project Detection Reference

## Build File Mapping

| Build File | Project Type | Install Command | Build Command | Test Command |
|------------|--------------|-----------------|---------------|--------------|
| `package.json` | JavaScript/TypeScript | `npm install` | `npm run build` | `npm test` |
| `build.gradle` / `build.gradle.kts` | Java/Kotlin | - | `./gradlew build` | `./gradlew test` |
| `pom.xml` | Java (Maven) | `mvn install` | `mvn package` | `mvn test` |
| `requirements.txt` | Python | `pip install -r requirements.txt` | - | `pytest` |
| `pyproject.toml` | Python | `poetry install` | `poetry build` | `poetry run pytest` |
| `Cargo.toml` | Rust | - | `cargo build` | `cargo test` |
| `go.mod` | Go | `go mod download` | `go build` | `go test ./...` |
| `composer.json` | PHP | `composer install` | - | `composer test` |
| `Gemfile` | Ruby | `bundle install` | - | `bundle exec rspec` |
| `*.csproj` / `*.sln` | C# / .NET | `dotnet restore` | `dotnet build` | `dotnet test` |

## Framework Detection

| Build File | Check For | Framework |
|------------|-----------|-----------|
| `package.json` | `react` in dependencies | React |
| `package.json` | `vue` in dependencies | Vue |
| `package.json` | `next` in dependencies | Next.js |
| `package.json` | `express` in dependencies | Express |
| `build.gradle` | `net.minecraftforge.gradle` | Minecraft Forge |
| `build.gradle` | `fabric-loom` | Minecraft Fabric |
| `build.gradle` | `org.springframework.boot` | Spring Boot |
| `pom.xml` | `spring-boot-starter` | Spring Boot |
| `requirements.txt` | `django` | Django |
| `requirements.txt` | `flask` | Flask |
| `requirements.txt` | `fastapi` | FastAPI |

## Language-Specific Conventions

### JavaScript/TypeScript
- **Naming**: camelCase functions, PascalCase components/classes
- **Files**: kebab-case.ts or PascalCase.tsx for components
- **Comment syntax**: `/** JSDoc */`

### Java/Kotlin
- **Naming**: camelCase methods, PascalCase classes
- **Files**: PascalCase.java matching class name
- **Comment syntax**: `/** Javadoc */`

### Python
- **Naming**: snake_case functions, PascalCase classes
- **Files**: snake_case.py
- **Comment syntax**: `"""Docstrings"""`

### Go
- **Naming**: camelCase private, PascalCase public
- **Files**: snake_case.go
- **Comment syntax**: `// Go doc`

### Rust
- **Naming**: snake_case functions, PascalCase types
- **Files**: snake_case.rs
- **Comment syntax**: `/// rustdoc`

### C#
- **Naming**: PascalCase methods and classes
- **Files**: PascalCase.cs
- **Comment syntax**: `/// <summary>XML doc</summary>`
