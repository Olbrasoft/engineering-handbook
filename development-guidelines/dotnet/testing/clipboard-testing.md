# Clipboard Testing

How to test code that interacts with system clipboard.

## Why Special Approach?

Clipboard has special requirements:

- **Thread requirements** - Some APIs require STA (Single-Threaded Apartment) thread
- **Side effects** - Operations affect user's system (clipboard affects other apps)
- **Isolation** - Tests should not depend on system state

## The Problem

Windows clipboard API requires:
1. **STA thread** - `SetText()`/`GetText()` throws exception on non-STA thread
2. **Isolation** - Tests shouldn't modify user's actual clipboard

## Solution: Abstraction + Mocking

**Step 1: Create interface**

```csharp
public interface IClipboard
{
    void SetText(string text);
    string? GetText();
    bool ContainsText();
}
```

**Step 2: Implement for production**

```csharp
public class SystemClipboard : IClipboard
{
    public void SetText(string text) => Clipboard.SetText(text);
    public string? GetText() => Clipboard.GetText();
    public bool ContainsText() => Clipboard.ContainsText();
}
```

**Step 3: Mock in tests**

```csharp
using Moq;

public class MyServiceTests
{
    private readonly Mock<IClipboard> _mockClipboard;
    private readonly MyService _service;

    public MyServiceTests()
    {
        _mockClipboard = new Mock<IClipboard>();
        _service = new MyService(_mockClipboard.Object);
    }

    [Fact]
    public void CopyToClipboard_WithValidText_CallsSetText()
    {
        // Arrange
        var text = "Hello World";

        // Act
        _service.CopyToClipboard(text);

        // Assert
        _mockClipboard.Verify(c => c.SetText(text), Times.Once);
    }

    [Fact]
    public void GetFromClipboard_WhenTextExists_ReturnsText()
    {
        // Arrange
        _mockClipboard.Setup(c => c.GetText()).Returns("Expected");

        // Act
        var result = _service.GetFromClipboard();

        // Assert
        Assert.Equal("Expected", result);
    }
}
```

## When You MUST Test Real Clipboard (Rare)

If you absolutely need to test real clipboard (e.g., testing `SystemClipboard` implementation itself):

**Required package:**
```xml
<PackageReference Include="Xunit.StaFact" Version="1.1.11" />
```

**Test with `[StaFact]`:**
```csharp
using Xunit;

public class SystemClipboardTests
{
    [StaFact] // ← Runs on STA thread
    public void SetText_WithValidText_SetsClipboardContent()
    {
        // Arrange
        var clipboard = new SystemClipboard();
        var originalContent = Clipboard.GetText(); // Save original
        
        try
        {
            // Act
            clipboard.SetText("Test");

            // Assert
            Assert.Equal("Test", Clipboard.GetText());
        }
        finally
        {
            // Cleanup - restore original content
            if (!string.IsNullOrEmpty(originalContent))
                Clipboard.SetText(originalContent);
        }
    }
}
```

**⚠️ Warning:** Real clipboard tests:
- Affect user's actual clipboard
- Can interfere with other applications
- Should be marked with `[SkipOnCIFact]` if affecting CI

## Best Practices

### ✅ DO

- ✅ Create `IClipboard` interface for abstraction
- ✅ Use dependency injection to provide implementation
- ✅ Mock clipboard in unit tests
- ✅ Use `[StaFact]` only when testing actual implementation
- ✅ Restore original clipboard content after real tests

### ❌ DON'T

- ❌ Call real clipboard in unit tests
- ❌ Depend on clipboard state in tests
- ❌ Forget cleanup in real clipboard tests
- ❌ Run real clipboard tests on CI without `[SkipOnCIFact]`

## Required Packages

```xml
<!-- For clipboard STA testing (if needed) -->
<PackageReference Include="Xunit.StaFact" Version="1.1.11" />
```

## See Also

- [Unit Tests](unit-tests-testing.md) - General unit testing guide
- [Integration Tests](integration-tests-testing.md) - Testing with real services
