# AGENTS.md - Feel-Chat Backend

## Project Overview
- **Framework**: Spring Boot 4.0.2 with Java 25
- **Build Tool**: Maven
- **Database**: PostgreSQL with JPA
- **Key Dependencies**: Spring Security, WebSocket, Spring Data JPA, PostgreSQL

---

## Build Commands

### Environment Setup
To use Java 25 and Maven, run the following command to enter the development shell:
```bash
nix develop .#backend
```

### Standard Commands
```bash
# Build the project
./mvnw clean install

# Run the application
./mvnw spring-boot:run

# Run tests
./mvnw test
```

### Single Test Execution
```bash
# Run a specific test class
./mvnw test -Dtest=BackendApplicationTests

# Run a specific test method
./mvnw test -Dtest=BackendApplicationTests#contextLoads

# Run tests with verbose output
./mvnw test -Dsurefire.useFile=false
```

### Development
```bash
# Compile without running tests
./mvnw compile

# Package as JAR
./mvnw package

# Skip tests during build
./mvnw clean install -DskipTests
```

---

## Code Style Guidelines

### Naming Conventions
- **Classes**: PascalCase (e.g., `UserService`, `UserController`)
- **Methods**: camelCase (e.g., `saveUser`, `findUser`)
- **Variables**: camelCase (e.g., `userService`, `sessionId`)
- **Constants**: UPPER_SNAKE_CASE (e.g., `MAX_RETRY_COUNT`)
- **Packages**: lowercase (e.g., `backend.model.service`)

### Package Structure
```
backend/
├── model/
│   ├── entity/     # JPA entities
│   ├── repository/ # Spring Data repositories
│   ├── service/    # Business logic
│   └── controller/rest/ # REST controllers
├── configuration/ # App configuration classes
└── BackendApplication.java
```

### Import Organization
1. Java standard library
2. Spring Framework imports
3. Third-party libraries
4. Project internal imports

Example:
```java
import java.util.UUID;
import java.util.Optional;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import backend.model.entity.User;
import backend.model.service.UserService;
```

### Formatting
- **Indentation**: 2 spaces (not tabs)
- **Line length**: Keep lines under 120 characters when practical
- **Braces**: Same-line opening braces for methods/classes

### Types
- Use Java 25 features where appropriate (e.g., `var` for local variable type inference)
- Prefer `Optional` for methods that may return null
- Use primitive types when nullability is not a concern

### Entity Guidelines
- Use JPA annotations (`@Entity`, `@Table`, `@Column`)
- Use `@JsonIgnore` to prevent circular serialization
- Use UUID for ID fields with database-generated values
- Initialize collections to avoid NPE: `new HashSet<>()`

### Error Handling
- Use meaningful HTTP status codes (200, 201, 400, 401, 404, 409, 500)
- Return appropriate error messages in response body when needed
- Use try-catch blocks for parsing operations (e.g., JSON parsing)
- Avoid exposing stack traces in production responses

### REST Controller Patterns
- Use `@RestController` with `@RequestMapping` for route prefixes
- Use appropriate HTTP verbs: `@PostMapping`, `@GetMapping`, `@PatchMapping`, `@PutMapping`
- Use `@RequestHeader` for headers like `session-id`
- Return `ResponseEntity<T>` for flexible response handling

### Service Layer Patterns
- Use `@Service` annotation for service classes
- Use constructor injection (not `@Autowired` on fields)
- Use `@Transactional` for methods that modify data
- Validate inputs before processing

### Security
- Never log or expose passwords in plain text
- Use `PasswordEncoder` from Spring Security for password hashing
- Validate session before sensitive operations

### Testing
- Place tests in `src/test/java/backend/`
- Use `@SpringBootTest` for integration tests
- Use `@Test` from JUnit 5
- Keep test names descriptive: `methodName_shouldDoX_whenY()`

---

## Configuration

### Application Properties
Database and application configuration is in `src/main/resources/application.properties`.

### Database
- Uses PostgreSQL with native UUID generation: `gen_random_uuid()`
- Default timestamps: `CURRENT_TIMESTAMP`

---

## Notes for Agents

1. **Database Dependency**: Tests require a running PostgreSQL instance. Configure via `application.properties`.

2. **Session Management**: Session-based authentication uses UUIDs stored in headers (`session-id`).

3. **WebSocket**: The project includes WebSocket support (`spring-boot-starter-websocket`).

4. **Security**: Uses `spring-security-crypto` for password encoding.

5. **Email Service**: Currently makes HTTP calls to external service at `http://localhost:9090/api/v1/users/send`.
