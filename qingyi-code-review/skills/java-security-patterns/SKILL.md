---
name: java-security-patterns
description: Java security best practices covering OWASP Top 10, input validation, cryptographic implementations, secrets management, and dependency vulnerabilities. Use when conducting security reviews or implementing secure Java code.
---

# Java Security Patterns

## Overview

This skill covers general Java security best practices applicable to Minecraft mods and Java applications. Complements `minecraft-code-review-patterns` with broader security concepts.

## OWASP Top 10 (2021)

### 1. Broken Access Control

**Vulnerability**: Users can act outside intended permissions

**Example**:
```java
// ❌ BAD: Client-side permission check
@ClientOnly
public void executeCommand() {
    if (LocalPlayer.hasPermission("admin")) {  // ← Can be bypassed!
        server.executeAdminCommand();
    }
}
```

**Fix**: Server-side authorization
```java
// ✅ GOOD: Server validates
@ServerOnly
public void executeCommand(Player player) {
    if (hasServerPermission(player, "admin")) {  // ← Server checks
        executeAdminCommand();
    }
}
```

---

### 2. Cryptographic Failures

**Vulnerability**: Weak encryption, hardcoded keys

**Example**:
```java
// ❌ BAD: Weak algorithm
Cipher cipher = Cipher.getInstance("DES");  // ← DES is broken!
```

**Fix**: Use modern algorithms
```java
// ✅ GOOD: AES-256-GCM
Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding");
SecretKey key = generateKey(256);  // 256-bit key
```

**Best Practices**:
- Use AES-256 for symmetric encryption
- Use RSA-2048+ or ECC for asymmetric
- Never hardcode keys in source code
- Use SecureRandom, not Random

---

### 3. Injection

**Vulnerability**: Untrusted data executed as code

**SQL Injection**:
```java
// ❌ BAD: String concatenation
String query = "SELECT * FROM users WHERE name = '" + userName + "'";
// Attacker: userName = "admin' OR '1'='1"
```

**Fix**: Prepared statements
```java
// ✅ GOOD: Parameterized query
PreparedStatement stmt = conn.prepareStatement("SELECT * FROM users WHERE name = ?");
stmt.setString(1, userName);
```

**Command Injection**:
```java
// ❌ BAD: Execute user input
Runtime.getRuntime().exec("ping " + userInput);
// Attacker: userInput = "google.com & rm -rf /"
```

**Fix**: Validate and sanitize
```java
// ✅ GOOD: Whitelist validation
if (userInput.matches("[a-zA-Z0-9\\.]+")) {  // Only alphanumeric and dots
    Runtime.getRuntime().exec("ping " + userInput);
}
```

---

### 4. Insecure Design

**Principle**: Security by design, not as afterthought

**Example**: Password reset without rate limiting
```java
// ❌ BAD: No rate limiting
public void resetPassword(String email) {
    sendResetEmail(email);  // Attacker can spam this
}
```

**Fix**: Rate limiting
```java
// ✅ GOOD: Rate limit per IP
private final Map<String, RateLimiter> limiters = new HashMap<>();

public void resetPassword(String email, String clientIP) {
    RateLimiter limiter = limiters.computeIfAbsent(clientIP,
        k -> RateLimiter.create(1.0 / 60.0));  // 1 request per minute

    if (limiter.tryAcquire()) {
        sendResetEmail(email);
    } else {
        throw new RateLimitException("Too many requests");
    }
}
```

---

### 5. Security Misconfiguration

**Vulnerability**: Default configurations, unnecessary features enabled

**Examples**:
- Leaving debug endpoints enabled in production
- Default admin passwords
- Unnecessary services running
- Verbose error messages revealing internals

**Fix**: Secure defaults
```java
// ✅ Production configuration
public class SecurityConfig {
    public static final boolean DEBUG_MODE = false;  // ← Disabled in prod
    public static final boolean DETAILED_ERRORS = false;
    public static final String ADMIN_PASSWORD = System.getenv("ADMIN_PASSWORD");  // ← From env var
}
```

---

### 6. Vulnerable Components

**Vulnerability**: Using libraries with known vulnerabilities

**Tools**:
- **OWASP Dependency-Check**: Scans dependencies for CVEs
- **Snyk**: Continuous monitoring
- **GitHub Dependabot**: Auto PR for updates

**Gradle Integration**:
```gradle
plugins {
    id "org.owasp.dependencycheck" version "8.4.0"
}

dependencyCheck {
    failBuildOnCVSS 7  // Fail if CVSS score ≥ 7
}
```

**Best Practices**:
- Keep dependencies updated
- Remove unused dependencies
- Monitor CVE databases
- Use dependency management tools

---

### 7. Authentication Failures

**Vulnerability**: Weak authentication mechanisms

**Examples**:
- No brute-force protection
- Weak password requirements
- Session fixation
- No multi-factor authentication

**Fix**: Secure authentication
```java
// ✅ Password hashing with BCrypt
import org.mindrot.jbcrypt.BCrypt;

public class PasswordService {
    public String hashPassword(String plaintext) {
        return BCrypt.hashpw(plaintext, BCrypt.gensalt(12));  // Work factor 12
    }

    public boolean verifyPassword(String plaintext, String hashed) {
        return BCrypt.checkpw(plaintext, hashed);
    }
}
```

**Never**:
- Store passwords in plaintext
- Use MD5 or SHA1 for passwords (use BCrypt/Argon2)
- Log passwords
- Send passwords over unencrypted connections

---

### 8. Software and Data Integrity Failures

**Vulnerability**: Unsigned updates, deserialization attacks

**Java Deserialization**:
```java
// ❌ DANGEROUS: Arbitrary code execution
ObjectInputStream ois = new ObjectInputStream(userInputStream);
Object obj = ois.readObject();  // ← Attacker can execute code!
```

**Fix**: Avoid Java serialization, use JSON
```java
// ✅ SAFE: Use Gson or Jackson
Gson gson = new Gson();
MyObject obj = gson.fromJson(userInput, MyObject.class);
```

---

### 9. Security Logging Failures

**Vulnerability**: Insufficient logging, logs not monitored

**What to Log**:
- Authentication attempts (success/failure)
- Authorization failures
- Input validation failures
- Application errors

**How to Log Securely**:
```java
// ✅ GOOD: Sanitized logging
logger.info("Login attempt for user: {}", sanitize(userName));

private String sanitize(String input) {
    return input.replaceAll("[^a-zA-Z0-9]", "");  // Remove special chars
}
```

**Never Log**:
- Passwords
- API keys
- Session tokens
- Credit card numbers

---

### 10. Server-Side Request Forgery (SSRF)

**Vulnerability**: Server fetches attacker-controlled URL

**Example**:
```java
// ❌ BAD: No validation
public String fetchURL(String url) {
    return HttpClient.get(url);  // Attacker: url = "http://localhost:8080/admin"
}
```

**Fix**: Whitelist domains
```java
// ✅ GOOD: Whitelist
private static final Set<String> ALLOWED_DOMAINS = Set.of("api.example.com", "cdn.example.com");

public String fetchURL(String url) {
    URI uri = new URI(url);
    if (!ALLOWED_DOMAINS.contains(uri.getHost())) {
        throw new SecurityException("Domain not allowed");
    }
    return HttpClient.get(url);
}
```

---

## Input Validation

### Whitelist vs Blacklist

**Always prefer whitelist** (allow known good) over blacklist (block known bad)

```java
// ❌ BAD: Blacklist
if (input.contains("<script>") || input.contains("DROP TABLE")) {
    throw new ValidationException();
}
// Attacker: <SCRIPT> or DrOp TaBlE (bypass via case)

// ✅ GOOD: Whitelist
if (!input.matches("[a-zA-Z0-9 ]+")) {  // Only alphanumeric and spaces
    throw new ValidationException();
}
```

### Context-Specific Validation

```java
// Email
if (!email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$")) {
    throw new ValidationException("Invalid email");
}

// UUID
UUID.fromString(input);  // Throws if invalid

// Integer with range
int value = Integer.parseInt(input);
if (value < 0 || value > 100) {
    throw new ValidationException("Value must be 0-100");
}
```

---

## Secrets Management

### Never Hardcode Secrets

```java
// ❌ BAD: Hardcoded API key
public static final String API_KEY = "sk_live_abc123...";  // ← Committed to Git!

// ✅ GOOD: Environment variable
public static final String API_KEY = System.getenv("API_KEY");

// ✅ BETTER: Secret management service
public static final String API_KEY = SecretsManager.getSecret("api-key");
```

### Environment Variables

```java
// Read from environment
String dbPassword = System.getenv("DB_PASSWORD");
if (dbPassword == null) {
    throw new IllegalStateException("DB_PASSWORD not set");
}
```

**Set in environment**:
```bash
export DB_PASSWORD=secret123
java -jar myapp.jar
```

---

## Secure Random Numbers

```java
// ❌ BAD: Predictable
Random random = new Random();
int token = random.nextInt();  // ← Predictable sequence!

// ✅ GOOD: Cryptographically secure
SecureRandom random = new SecureRandom();
byte[] token = new byte[32];
random.nextBytes(token);
```

**Use SecureRandom for**:
- Session tokens
- Password reset tokens
- Encryption keys
- CSRF tokens

---

## Thread Safety in Security Code

```java
// ❌ BAD: Race condition
private int failedAttempts = 0;

public void login(String password) {
    if (!verify(password)) {
        failedAttempts++;  // ← Not thread-safe!
        if (failedAttempts > 5) {
            lockAccount();
        }
    }
}

// ✅ GOOD: Atomic operation
private final AtomicInteger failedAttempts = new AtomicInteger(0);

public void login(String password) {
    if (!verify(password)) {
        int attempts = failedAttempts.incrementAndGet();
        if (attempts > 5) {
            lockAccount();
        }
    }
}
```

---

## Security Checklist

- [ ] All inputs validated (whitelist)
- [ ] Prepared statements for SQL queries
- [ ] Passwords hashed with BCrypt/Argon2
- [ ] No secrets in source code
- [ ] SecureRandom for cryptographic operations
- [ ] HTTPS for all network communication
- [ ] Authentication on server side
- [ ] Authorization checked for every operation
- [ ] Dependencies scanned for vulnerabilities
- [ ] Security logging enabled
- [ ] Error messages don't reveal internals
- [ ] Rate limiting on authentication endpoints

---

## See Also

- [Minecraft Code Review Patterns](../minecraft-code-review-patterns/SKILL.md) - Mod-specific security
