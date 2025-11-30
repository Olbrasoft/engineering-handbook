1. Single Responsibility Principle (SRP)
A class/module/component should have only one reason to change.

Modern 2025 interpretation:
“One responsibility = one actor”.
If two different people/teams (e.g., finance team + DBA team) have to touch the same class, SRP is violated.
Bad: One class that calculates salary, saves to database, and generates a PDF report.
Good: Three separate classes/components – one for calculation, one for persistence, one for reporting.

2. Open/Closed Principle (OCP)
Software entities should be open for extension but closed for modification.

2025 rule of thumb:
When you add a new feature (new payment method, new export format, new notification channel), you create a new class – you never modify old, already-tested code.
Classic violation: giant switch/if-else chain that keeps growing.
Modern solution: new implementations are discovered automatically via plugins, registration conventions, attributes, or configuration – no switch statements.

3. Liskov Substitution Principle (LSP)
Subtypes must be behaviorally substitutable for their base types.

If you can’t replace a base class object with a derived class object without breaking the program, LSP is violated.
Most common violations in 2025:
Derived class throws a new exception not declared in the base contract.
Derived class returns null or a broader type than expected.
Derived class strengthens preconditions or weakens postconditions.

Famous example: Square inheriting from Rectangle and overriding setters so both sides are always equal → LSP violation.

4. Interface Segregation Principle (ISP)
Clients should not be forced to depend on interfaces they do not use.

Prefer many small, client-specific interfaces over one “fat” interface.
2025 reality: almost nobody writes God interfaces with 15–30 methods anymore.
Correct approach: role-based interfaces (e.g., IReader, IWriter, IAuditable, IClosable…). A client implements only what it actually needs.

5. Dependency Inversion Principle (DIP)
High-level modules should not depend on low-level modules. Both should depend on abstractions.
Abstractions should not depend on details. Details should depend on abstractions.

In practice:
Never instantiate concrete dependencies inside a class (new SqlLogger()).
All dependencies are injected (usually via constructor) as abstractions → classic Dependency Injection.

Result = extremely easy unit testing (mocks/stubs/fakes) and swapping implementations (real DB ↔ in-memory, SMTP ↔ console, etc.).

SOLID + Unit Testing – Universal Rules (2025)

Each unit test verifies exactly one behavior (thanks to SRP).
Tests are completely isolated – no real database, network, or file system.
Every external dependency is replaced with a test double (mock/stub/fake/spy) – made possible by DIP.
Every test follows the AAA pattern: Arrange → Act → Assert.
Test names describe: [MethodUnderTest]_[Scenario]_[ExpectedResult].

SOLID Cheat-Sheet 2025 – One-Page Summary

PrincipleEveryday meaning (2025)Typical violation todayModern fix (language-agnostic)SRPOne class = one job = one team/actorController/Service that does everythingFeature folders, vertical slices, CQRSOCPAdd new behavior → add new class, never change old codeGiant switch/if-else that keeps growingPlugin system, auto-registration, conventionsLSPChild class 100% replaceable by parentSquare ⊃ Rectangle, Penguin ⊃ BirdPrefer composition or discriminated unionsISPMany small, focused interfaces“God interface” with 20+ methodsRole interfaces (Reader/Writer/…)DIPDepend on abstractions + inject everythingnew Database() inside business logicDependency Injection container + mocks
This version is timeless, framework-independent, and perfect for onboarding, posters, or internal wiki pages in any company in 2025 and beyond.
Whenever you need a language-specific version (C#/.NET, Python, TypeScript, Java/Kotlin, Rust…), just say the word and I’ll send it instantly.
