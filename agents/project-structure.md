# Project Structure

## Directory Layout

```
my_app/
├── lib/
│   ├── my_app/              # Core application logic
│   │   ├── application.ex   # Application entry point
│   │   ├── media/           # Media context
│   │   │   ├── image.ex     # Image schema
│   │   │   ├── folder.ex    # Folder schema
│   │   │   └── media.ex     # Context boundary module
│   │   └── repo.ex          # Ecto repository
│   │
│   └── my_app_web/          # Web interface
│       ├── components/      # Reusable UI components
│       ├── controllers/     # Traditional controllers
│       ├── live/            # LiveView modules
│       │   └── gallery_live.ex
│       ├── endpoint.ex      # Phoenix endpoint
│       ├── router.ex        # Route definitions
│       └── telemetry.ex     # Metrics and monitoring
│
├── priv/
│   ├── repo/
│   │   └── migrations/      # Database migrations
│   ├── static/              # Static assets
│   │   └── uploads/         # Uploaded images
│   └── gettext/             # Translations
│
├── test/
│   ├── my_app/              # Tests for core logic
│   │   └── media_test.exs
│   ├── my_app_web/          # Tests for web layer
│   │   └── live/
│   │       └── gallery_live_test.exs
│   ├── support/             # Test helpers
│   └── test_helper.exs
│
├── config/
│   ├── config.exs           # General config
│   ├── dev.exs              # Development config
│   ├── test.exs             # Test config
│   ├── prod.exs             # Production config
│   └── runtime.exs          # Runtime config
│
├── assets/                  # Frontend assets
│   ├── css/
│   ├── js/
│   └── vendor/
│
└── mix.exs                  # Project definition
```

## Context Boundaries

Phoenix encourages organizing code into contexts - modules that group related functionality.

### Media Context

The `Media` context handles all image and folder operations:

```elixir
# lib/my_app/media.ex - Public API
defmodule MyApp.Media do
  # Public functions that other contexts can call
  def list_images()
  def get_image!(id)
  def create_image(attrs)
  def update_image(image, attrs)
  def delete_image(image)

  def list_folders()
  def create_folder(attrs)
  def move_image_to_folder(image, folder)
end

# lib/my_app/media/image.ex - Schema
defmodule MyApp.Media.Image do
  use Ecto.Schema
  # Schema definition only
end

# lib/my_app/media/folder.ex - Schema
defmodule MyApp.Media.Folder do
  use Ecto.Schema
  # Schema definition only
end
```

### Web Layer

The web layer should be thin, delegating business logic to contexts:

```elixir
# lib/my_app_web/live/gallery_live.ex
defmodule MyAppWeb.GalleryLive do
  use MyAppWeb, :live_view

  alias MyApp.Media  # Import the context

  def handle_event("upload", params, socket) do
    # Delegate to context
    case Media.create_image(params) do
      {:ok, image} -> # Handle success
      {:error, changeset} -> # Handle error
    end
  end
end
```

## File Organization Rules

1. **One module per file**: File path should match module name
   - `MyApp.Media.Image` → `lib/my_app/media/image.ex`

2. **Contexts group related functionality**:
   - Keep schemas in context directory
   - Public API in main context module

3. **Web vs. Core**:
   - `lib/my_app/` = business logic, no web dependencies
   - `lib/my_app_web/` = web interface, depends on core

4. **Test mirrors source**:
   - `lib/my_app/media.ex` → `test/my_app/media_test.exs`

## Common Files

### application.ex
Starts the application and supervision tree:
```elixir
def start(_type, _args) do
  children = [
    MyApp.Repo,           # Database
    MyAppWeb.Telemetry,   # Metrics
    MyAppWeb.Endpoint     # Web server
  ]
  Supervisor.start_link(children, strategy: :one_for_one)
end
```

### router.ex
Defines routes:
```elixir
scope "/", MyAppWeb do
  pipe_through :browser

  live "/", GalleryLive, :index
  live "/folder/:id", GalleryLive, :folder
end
```

### repo.ex
Database access:
```elixir
defmodule MyApp.Repo do
  use Ecto.Repo,
    otp_app: :my_app,
    adapter: Ecto.Adapters.Postgres
end
```

## Configuration

Configuration is environment-specific:

- `config/config.exs` - Shared configuration
- `config/dev.exs` - Development (imports config.exs)
- `config/test.exs` - Test environment
- `config/prod.exs` - Production
- `config/runtime.exs` - Runtime configuration (env vars)

## Assets

Frontend assets in `assets/`:
- Compiled by esbuild
- Output to `priv/static/`
- Served by Phoenix endpoint

## Key Principles

1. **Contexts are boundaries**: Don't bypass contexts to access schemas directly from web layer
2. **Thin controllers/LiveViews**: Business logic goes in contexts
3. **One source of truth**: Each piece of data belongs to one context
4. **Dependencies flow inward**: Web depends on core, not vice versa
