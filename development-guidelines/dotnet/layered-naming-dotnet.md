# Layered Application Naming Conventions

How to name projects in multi-layered .NET applications (3-tier architecture).

## When to Use

- **Application type:** Multi-layered web/API applications
- **Architecture:** 3-tier (Data, Business, UI)
- **Examples:** Blog, VirtualAssistant, GitHub.Issues
- **NOT for:** Simple single-project libraries

## Project Naming Pattern

**Pattern:** `Olbrasoft.{Domain}.{Layer}[.{Technology}]`

| Layer | Project Name | Purpose |
|-------|-------------|---------|
| **Data (Core)** | `Olbrasoft.{Domain}.Data` | Entities, DTOs, Queries, Commands, Interfaces |
| **Data (EF)** | `Olbrasoft.{Domain}.Data.EntityFrameworkCore` | DbContext, Query/Command Handlers, Migrations |
| **Business (Abstractions)** | `Olbrasoft.{Domain}.Business.Abstractions` | Service/Facade interfaces (complex apps only) |
| **Business** | `Olbrasoft.{Domain}.Business` | Services, Facades, business logic |
| **UI (MVC)** | `Olbrasoft.{Domain}.AspNetCore.Mvc` | ASP.NET Core MVC application |
| **UI (API)** | `Olbrasoft.{Domain}.AspNetCore.Api` | ASP.NET Core Web API |

## Example: Blog Application

**Location:** `/home/jirka/Olbrasoft/Blog/`

```
Blog/
├── src/
│   ├── Olbrasoft.Blog.Data/                      # Data Layer (Core)
│   │   ├── Entities/
│   │   │   ├── Post.cs
│   │   │   ├── Category.cs
│   │   │   ├── Tag.cs
│   │   │   ├── Comment.cs
│   │   │   ├── NestedComment.cs
│   │   │   ├── Image.cs
│   │   │   └── Identity/
│   │   │       ├── BlogUser.cs
│   │   │       └── BlogRole.cs
│   │   ├── Dtos/
│   │   │   ├── PostDtos/
│   │   │   │   ├── PostDto.cs
│   │   │   │   ├── PostDetailDto.cs
│   │   │   │   └── PostEditDto.cs
│   │   │   ├── CategoryDtos/
│   │   │   ├── TagDtos/
│   │   │   └── CommentDtos/
│   │   ├── Queries/
│   │   │   ├── PostQueries/
│   │   │   │   ├── PostByIdQuery.cs
│   │   │   │   └── PostsPagedQuery.cs
│   │   │   ├── CategoryQueries/
│   │   │   ├── TagQueries/
│   │   │   └── CommentQueries/
│   │   └── Commands/
│   │       ├── PostSaveCommand.cs
│   │       ├── CategorySaveCommand.cs
│   │       ├── TagCommands/
│   │       └── CommentCommands/
│   │
│   ├── Olbrasoft.Blog.Data.EntityFrameworkCore/  # Data Layer (EF Implementation)
│   │   ├── BlogDbContext.cs
│   │   ├── Configurations/
│   │   │   └── EntityConfigurations/
│   │   │       ├── PostConfiguration.cs
│   │   │       ├── CategoryConfiguration.cs
│   │   │       └── TagConfiguration.cs
│   │   ├── QueryHandlers/
│   │   │   ├── PostQueryHandlers/
│   │   │   ├── CategoryQueryHandlers/
│   │   │   └── TagQueryHandlers/
│   │   └── CommandHandlers/
│   │       ├── PostSaveCommandHandler.cs
│   │       └── CategorySaveCommandHandler.cs
│   │
│   ├── Olbrasoft.Blog.Business/                  # Business Layer
│   │   ├── IPostService.cs                       # Service interfaces (root)
│   │   ├── ICategoryService.cs
│   │   ├── ITagService.cs
│   │   ├── ICommentService.cs
│   │   ├── IPostFacade.cs                        # Facade interfaces (root)
│   │   ├── Services/                             # Service implementations
│   │   │   ├── PostService.cs
│   │   │   ├── CategoryService.cs
│   │   │   ├── TagService.cs
│   │   │   └── CommentService.cs
│   │   ├── Facades/                              # Facade implementations
│   │   │   └── PostFacade.cs                     # Combines multiple services
│   │   └── ImageExtensionProvider.cs
│   │
│   └── Olbrasoft.Blog.AspNetCore.Mvc/            # UI Layer (MVC)
│       ├── Controllers/
│       ├── Views/
│       ├── Models/
│       ├── Areas/
│       │   └── Administration/
│       └── App_Data/
│
├── tests/
│   ├── Olbrasoft.Blog.Data.Tests/
│   ├── Olbrasoft.Blog.Business.Tests/
│   └── Olbrasoft.Blog.AspNetCore.Mvc.Tests/
│
└── Blog.sln
```

## Layer Responsibilities

### Data Layer (`.Data`)

**Purpose:** Core domain definitions without implementation details.

**Contains:**
- Entities (domain objects with business rules)
- DTOs (data transfer objects for queries)
- Query definitions (CQRS read operations)
- Command definitions (CQRS write operations)
- Repository interfaces

**Does NOT contain:**
- Database implementation (DbContext)
- External service clients
- Framework-specific code

**Example entity:**
```csharp
// Olbrasoft.Blog.Data/Entities/Post.cs
namespace Olbrasoft.Blog.Data.Entities;

public class Post : CreationInfo
{
    public string Title { get; set; } = string.Empty;
    public string Content { get; set; } = string.Empty;
    public int CategoryId { get; set; }
    public Category Category { get; set; }
    public ICollection<Comment> Comments { get; set; } = [];
    public ICollection<Tag> Tags { get; set; } = [];
}
```

### Data Implementation Layer (`.Data.EntityFrameworkCore`)

**Purpose:** Database implementation using Entity Framework Core.

**Contains:**
- `DbContext` class
- Entity configurations (Fluent API)
- Query handlers (implement queries from `.Data`)
- Command handlers (implement commands from `.Data`)
- Migrations

**Dependencies:**
- References `.Data` project
- EF Core packages

**Example DbContext:**
```csharp
// Olbrasoft.Blog.Data.EntityFrameworkCore/BlogDbContext.cs
namespace Olbrasoft.Blog.Data.EntityFrameworkCore;

public class BlogDbContext : IdentityDbContext<BlogUser, BlogRole, int>
{
    public DbSet<Category> Categories => Set<Category>();
    public DbSet<Post> Posts => Set<Post>();
    public DbSet<Comment> Comments => Set<Comment>();
    public DbSet<Tag> Tags => Set<Tag>();
}
```

### Business Layer (`.Business`)

**Purpose:** Business logic orchestration combining multiple data sources.

**Directory Structure:**

```
Olbrasoft.Blog.Business/
├── IPostService.cs              # Service interfaces (in root)
├── ICategoryService.cs
├── ITagService.cs
├── IPostFacade.cs               # Facade interfaces (in root)
├── Services/                    # Service implementations
│   ├── PostService.cs
│   ├── CategoryService.cs
│   └── TagService.cs
├── Facades/                     # Facade implementations
│   └── PostFacade.cs
└── ImageExtensionProvider.cs
```

**Contains:**
- **Interfaces (root):** Service and facade interfaces directly in project root
- **Services/:** Focused service implementations (one responsibility per service)
- **Facades/:** Orchestrating facades that combine multiple services
- Business logic that spans multiple entities
- Data aggregation from DB + APIs + files

**Dependencies:**
- References `.Data` project (uses interfaces, DTOs)
- May reference external API clients
- Does NOT reference `.Data.EntityFrameworkCore` directly

#### Services vs Facades

**Services** are focused on a single domain area:

```csharp
// Olbrasoft.Blog.Business/Services/PostService.cs
namespace Olbrasoft.Blog.Business.Services;

public class PostService : IPostService
{
    private readonly IQueryDispatcher _queryDispatcher;
    private readonly ICommandDispatcher _commandDispatcher;

    public async Task<PostDetailDto> GetPostDetailAsync(int id)
    {
        return await _queryDispatcher.DispatchAsync(new PostDetailByIdQuery(id));
    }

    public async Task<IEnumerable<PostDto>> GetPostsByUserAsync(int userId)
    {
        return await _queryDispatcher.DispatchAsync(new PostsByUserIdQuery(userId));
    }
}
```

**Facades** combine multiple services for complex use cases (see [Facade Pattern](https://en.wikipedia.org/wiki/Facade_pattern)):

```csharp
// Olbrasoft.Blog.Business/Facades/PostFacade.cs
namespace Olbrasoft.Blog.Business.Facades;

/// <summary>
/// Facade for post-related operations that require multiple services.
/// Used by controllers/pages that need combined functionality.
/// </summary>
public class PostFacade : IPostFacade
{
    private readonly IPostService _postService;
    private readonly ICategoryService _categoryService;
    private readonly ITagService _tagService;
    private readonly ICommentService _commentService;

    public PostFacade(
        IPostService postService,
        ICategoryService categoryService,
        ITagService tagService,
        ICommentService commentService)
    {
        _postService = postService;
        _categoryService = categoryService;
        _tagService = tagService;
        _commentService = commentService;
    }

    /// <summary>
    /// Gets all data needed for post detail page.
    /// </summary>
    public async Task<PostDetailPageModel> GetPostDetailPageAsync(int postId)
    {
        var post = await _postService.GetPostDetailAsync(postId);
        var tags = await _tagService.GetTagsByPostIdAsync(postId);
        var comments = await _commentService.GetCommentsByPostIdAsync(postId);
        var relatedPosts = await _postService.GetRelatedPostsAsync(post.CategoryId);

        return new PostDetailPageModel
        {
            Post = post,
            Tags = tags,
            Comments = comments,
            RelatedPosts = relatedPosts
        };
    }

    /// <summary>
    /// Gets all data needed for post edit page.
    /// </summary>
    public async Task<PostEditPageModel> GetPostEditPageAsync(int postId)
    {
        var post = await _postService.GetPostForEditAsync(postId);
        var allCategories = await _categoryService.GetAllCategoriesAsync();
        var allTags = await _tagService.GetAllTagsAsync();
        var selectedTags = await _tagService.GetTagsByPostIdAsync(postId);

        return new PostEditPageModel
        {
            Post = post,
            Categories = allCategories,
            AllTags = allTags,
            SelectedTagIds = selectedTags.Select(t => t.Id)
        };
    }
}
```

**When to use Facade:**
- Controller/page needs data from multiple services
- Complex use case that spans multiple domain areas
- Want to simplify controller code (thin controllers)

**When to use Service directly:**
- Simple operation involving single domain area
- API endpoint that returns single entity type

#### Business.Abstractions (Complex Applications)

For larger applications with multiple implementations or when you need to share interfaces across projects, separate interfaces into a dedicated project:

**Pattern:** `Olbrasoft.{Domain}.Business.Abstractions`

```
src/
├── Olbrasoft.Blog.Business.Abstractions/    # Interfaces only
│   ├── IPostService.cs
│   ├── ICategoryService.cs
│   ├── ITagService.cs
│   ├── IPostFacade.cs
│   └── Models/                              # Shared models/DTOs for business layer
│       ├── PostDetailPageModel.cs
│       └── PostEditPageModel.cs
│
├── Olbrasoft.Blog.Business/                 # Default implementation
│   ├── Services/
│   │   ├── PostService.cs
│   │   └── CategoryService.cs
│   └── Facades/
│       └── PostFacade.cs
│
└── Olbrasoft.Blog.Business.Caching/         # Alternative implementation (example)
    └── Services/
        └── CachedPostService.cs             # Decorator with caching
```

**When to use `.Business.Abstractions`:**
- Multiple implementations of same interface (e.g., caching decorator, mock for testing)
- Interfaces need to be shared across multiple projects
- Large team where interface contracts should be stable
- Microservices that need to share service contracts

**When NOT needed (keep interfaces in `.Business`):**
- Simple applications like Blog
- Single implementation per interface
- Small team, interfaces evolve with implementation

**Example with Abstractions:**

```csharp
// Olbrasoft.Blog.Business.Abstractions/IPostService.cs
namespace Olbrasoft.Blog.Business.Abstractions;

public interface IPostService
{
    Task<PostDetailDto> GetPostDetailAsync(int id);
    Task<IEnumerable<PostDto>> GetPostsByUserAsync(int userId);
}

// Olbrasoft.Blog.Business/Services/PostService.cs
namespace Olbrasoft.Blog.Business.Services;

public class PostService : IPostService  // Implements from Abstractions
{
    // Default implementation
}

// Olbrasoft.Blog.Business.Caching/Services/CachedPostService.cs
namespace Olbrasoft.Blog.Business.Caching.Services;

public class CachedPostService : IPostService  // Decorator pattern
{
    private readonly IPostService _inner;
    private readonly IMemoryCache _cache;

    public CachedPostService(IPostService inner, IMemoryCache cache)
    {
        _inner = inner;
        _cache = cache;
    }

    public async Task<PostDetailDto> GetPostDetailAsync(int id)
    {
        return await _cache.GetOrCreateAsync($"post:{id}", 
            async entry => await _inner.GetPostDetailAsync(id));
    }
}
```

**Dependency flow with Abstractions:**

```
UI Layer (AspNetCore.Mvc)
    │
    ├──► Business.Abstractions (interfaces)
    │
    └──► Business (implementation) ──► Business.Abstractions
```

### UI Layer (`.AspNetCore.Mvc`)

**Purpose:** Web presentation and user interaction.

**Contains:**
- Controllers / Razor Pages
- Views / Razor components
- View Models
- API endpoints
- Areas for admin sections

**Dependencies:**
- References `.Business` project
- References `.Data.EntityFrameworkCore` (for DI registration only)

## Dependency Flow

```
┌─────────────────────────────────────┐
│  Olbrasoft.Blog.AspNetCore.Mvc      │  ← UI Layer
│  (Controllers, Views)               │
│  Injects: IPostFacade, IPostService │
└──────────────┬──────────────────────┘
               │ references
               ▼
┌─────────────────────────────────────┐
│  Olbrasoft.Blog.Business            │  ← Business Layer
│  ├── Facades/ (combine services)    │
│  └── Services/ (focused logic)      │
└──────────────┬──────────────────────┘
               │ references
               ▼
┌─────────────────────────────────────┐
│  Olbrasoft.Blog.Data                │  ← Data Layer (Core)
│  (Entities, DTOs, Queries)          │
└──────────────▲──────────────────────┘
               │ references
┌──────────────┴──────────────────────┐
│  Olbrasoft.Blog.Data.EFCore         │  ← Data Layer (Implementation)
│  (DbContext, Handlers)              │
└─────────────────────────────────────┘

UI also references Data.EFCore for DI registration:
AspNetCore.Mvc ──► Data.EntityFrameworkCore (DI only)
```

### Controller Usage

**Using Facade (complex page):**
```csharp
// Olbrasoft.Blog.AspNetCore.Mvc/Controllers/PostController.cs
public class PostController : Controller
{
    private readonly IPostFacade _postFacade;

    public PostController(IPostFacade postFacade)
    {
        _postFacade = postFacade;
    }

    public async Task<IActionResult> Detail(int id)
    {
        // Facade provides all data for the page
        var model = await _postFacade.GetPostDetailPageAsync(id);
        return View(model);
    }
}
```

**Using Service directly (simple API):**
```csharp
// Olbrasoft.Blog.AspNetCore.Mvc/Controllers/Api/PostsApiController.cs
[ApiController]
[Route("api/posts")]
public class PostsApiController : ControllerBase
{
    private readonly IPostService _postService;

    public PostsApiController(IPostService postService)
    {
        _postService = postService;
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> Get(int id)
    {
        var post = await _postService.GetPostDetailAsync(id);
        return Ok(post);
    }
}
```

## Alternative Data Providers

When supporting multiple databases or ORMs:

| Provider | Project Name |
|----------|-------------|
| EF Core (default) | `Olbrasoft.Blog.Data.EntityFrameworkCore` |
| FreeSql | `Olbrasoft.Blog.Data.FreeSql` |
| Dapper | `Olbrasoft.Blog.Data.Dapper` |
| PostgreSQL migrations | `Olbrasoft.Blog.Migrations.PostgreSQL` |

**Blog example with FreeSql:**
```
src/
├── Olbrasoft.Blog.Data/
├── Olbrasoft.Blog.Data.EntityFrameworkCore/  # SQL Server
├── Olbrasoft.Blog.Data.FreeSql/              # Alternative ORM
└── Olbrasoft.Blog.Business/
```

## External Services Layer

For applications integrating external APIs, create separate projects:

| Service | Project Name |
|---------|-------------|
| GitHub API | `Olbrasoft.{Domain}.GitHub` |
| Voice services | `Olbrasoft.{Domain}.Voice` |
| Email service | `Olbrasoft.{Domain}.Email` |

**Example (VirtualAssistant):**
```
src/
├── Olbrasoft.VirtualAssistant.Data/
├── Olbrasoft.VirtualAssistant.Data.EntityFrameworkCore/
├── Olbrasoft.VirtualAssistant.Core/           # Business logic
├── Olbrasoft.VirtualAssistant.GitHub/         # GitHub API client
├── Olbrasoft.VirtualAssistant.Voice/          # TTS/STT services
├── Olbrasoft.VirtualAssistant.PushToTalk/     # Input handling
└── Olbrasoft.VirtualAssistant.Service/        # ASP.NET Core host
```

## Test Projects

Each source project has its own test project:

| Source | Test |
|--------|------|
| `Olbrasoft.Blog.Data` | `Olbrasoft.Blog.Data.Tests` |
| `Olbrasoft.Blog.Business` | `Olbrasoft.Blog.Business.Tests` |
| `Olbrasoft.Blog.AspNetCore.Mvc` | `Olbrasoft.Blog.AspNetCore.Mvc.Tests` |

See: [Testing Guide](testing/index-testing.md)

## See Also

- [.NET Guidelines Index](index-dotnet.md) - Overview of .NET standards
- [Project Structure](project-structure-dotnet.md) - General project layout
- [Architectural Patterns](design-patterns/architectural-patterns-design-patterns.md) - Layered vs Clean Architecture
- [SOLID Principles](solid-principles/solid-principles.md) - Dependency Inversion
