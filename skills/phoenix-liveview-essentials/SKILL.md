---
name: phoenix-liveview-essentials
description: Use when writing LiveView modules or HEEx templates — mount/handle_params lifecycle, assigns, streams, events, components.
file_patterns:
  - "**/live/**/*.ex"
  - "**/*_live.ex"
  - "**/*.html.heex"
  - "**/live/**/*.html.heex"
auto_suggest: true
---

# Phoenix LiveView Essentials

## RULES — Follow these with no exceptions

1. **Always add @impl true** before every callback (mount, handle_event, handle_info, render)
2. **Initialize assigns before they're accessed in render/1** — use mount/3 for static defaults, handle_params/3 for URL-dependent assigns (pagination, filters, sorting)
3. **Check connected?(socket)** before PubSub subscriptions, timers, or side effects
4. **Use Map.get(assigns, :key, default)** for optional assigns in helper functions
5. **Return proper tuples** — `{:ok, socket}` from mount, `{:noreply, socket}` from handle_event
6. **Use `with` for error handling** in event handlers — assign errors to socket, don't crash
7. **`auto_upload: true` works with submit, but entries must be fully uploaded before you consume them** — check `entry.done?` / rely on `consume_uploaded_entries` only after progress completes; default to manual uploads unless you need incremental upload UX
8. **Check `core_components.ex` for existing components** before creating custom ones
9. **Never query the database directly from LiveViews** — call context functions instead

---

## Critical Concept: Two-Phase Rendering

**LiveView renders happen in TWO phases:**

1. **Static/Disconnected Render** - Initial HTTP request
   - No WebSocket connection
   - `connected?(socket)` returns `false`
   - Side effects (PubSub, timers) won't work

2. **Connected Render** - WebSocket established
   - Full live functionality active
   - `connected?(socket)` returns `true`
   - Events and live updates work

**Common Bug:** Accessing uninitialized assigns during static render crashes with `KeyError`.

**Solution:** Initialize assigns before render — use mount/3 for static defaults, handle_params/3 for URL-dependent state.

---

## LiveView Lifecycle

### Mount Callback

```elixir
@impl true
def mount(_params, _session, socket) do
  # Initialize static defaults here; URL-dependent assigns go in handle_params
  socket =
    socket
    |> assign(:user, nil)
    |> assign(:loading, false)
    |> assign(:data, [])

  # Only subscribe when connected
  if connected?(socket) do
    Phoenix.PubSub.subscribe(MyApp.PubSub, "topic")
  end

  {:ok, socket}
end
```

**Why check connected?** PubSub subscriptions and timers only work with WebSocket connection.

### Handle Event

Use pattern matching for different actions.

```elixir
@impl true
def handle_event("save", %{"post" => post_params}, socket) do
  case Posts.create_post(post_params) do
    {:ok, post} ->
      socket =
        socket
        |> put_flash(:info, "Created!")
        |> assign(:post, post)

      {:noreply, socket}

    {:error, changeset} ->
      {:noreply, assign(socket, :changeset, changeset)}
  end
end

@impl true
def handle_event("delete", %{"id" => id}, socket) do
  Posts.delete_post(id)
  {:noreply, assign(socket, :posts, Posts.list_posts())}
end
```

### Handle Info

Handle async messages and PubSub broadcasts.

```elixir
@impl true
def handle_info({:post_created, post}, socket) do
  {:noreply, update(socket, :posts, fn posts -> [post | posts] end)}
end

@impl true
def handle_info(%{event: "presence_diff"}, socket) do
  {:noreply, assign(socket, :online_users, get_presence_count())}
end
```

### Handle Params

Respond to URL changes (called in BOTH render phases).

```elixir
@impl true
def handle_params(%{"id" => id}, _uri, socket) do
  # This runs during static AND connected render
  post = Posts.get_post!(id)

  if connected?(socket) do
    # Only subscribe when connected
    Phoenix.PubSub.subscribe(MyApp.PubSub, "post:#{id}")
  end

  {:noreply, assign(socket, :post, post)}
end

@impl true
def handle_params(_params, _uri, socket) do
  {:noreply, socket}
end
```

## Socket Assigns

Use `assign/2` or `assign/3` to update socket state.

```elixir
# Single assign
socket = assign(socket, :count, 0)

# Multiple assigns
socket = assign(socket, count: 0, name: "User", active: true)

# Update existing assign
socket = update(socket, :count, &(&1 + 1))
```

### Safe Assign Access

**In render/1:** Direct access is safe if initialized in mount.

```elixir
@impl true
def mount(_params, _session, socket) do
  {:ok, assign(socket, :count, 0)}
end

@impl true
def render(assigns) do
  ~H"""
  <p>Count: <%= @count %></p>  <!-- Safe -->
  """
end
```

**In helper functions:** Use Map.get for optional assigns.

```elixir
# ❌ BAD - Crashes if not a map with :name
defp format_user(%{name: name}), do: name

# ✅ GOOD - Handles nil case
defp format_user(socket) do
  case Map.get(socket.assigns, :current_user) do
    nil -> "Guest"
    user -> user.name
  end
end
```

## Temporary Assigns

Use temporary assigns for large collections that don't need to persist.

```elixir
@impl true
def mount(_params, _session, socket) do
  socket = assign(socket, :posts, [])
  {:ok, socket, temporary_assigns: [posts: []]}
end
```

For collections, prefer **streams** (below) — the current recommended mechanism; `temporary_assigns`
remains useful for one-shot large payloads that aren't managed as a growing/shrinking collection.

## Flash Messages

Use `put_flash/3` and `clear_flash/2` for user feedback.

```elixir
@impl true
def handle_event("save", params, socket) do
  case save_data(params) do
    {:ok, _} ->
      socket = put_flash(socket, :info, "Saved successfully!")
      {:noreply, socket}

    {:error, _} ->
      socket = put_flash(socket, :error, "Failed to save")
      {:noreply, socket}
  end
end
```

## Live Navigation

Use `push_navigate/2` or `push_patch/2` for navigation.

```elixir
# Full page reload (new LiveView)
{:noreply, push_navigate(socket, to: ~p"/users")}

# Patch (same LiveView, different params)
{:noreply, push_patch(socket, to: ~p"/posts/#{post}")}
```

## Streams

Use streams for efficient rendering of large lists.

```elixir
@impl true
def mount(_params, _session, socket) do
  {:ok, stream(socket, :posts, Posts.list_posts())}
end

@impl true
def handle_event("add", %{"post" => attrs}, socket) do
  {:ok, post} = Posts.create_post(attrs)
  {:noreply, stream_insert(socket, :posts, post, at: 0)}
end

@impl true
def handle_event("delete", %{"id" => id}, socket) do
  Posts.delete_post(id)
  {:noreply, stream_delete_by_dom_id(socket, :posts, "posts-#{id}")}
end
```

## Components

Extract reusable UI into function components.

```elixir
def card(assigns) do
  ~H"""
  <div class="card">
    <h3><%= @title %></h3>
    <p><%= @content %></p>
  </div>
  """
end

# Usage in template
<.card title="Hello" content="World" />
```

## Form Binding

Bind forms to changesets for validation.

```heex
<%!-- Phoenix 1.8 removed the old simple-form component; use <.form> --%>
<.form for={@form} phx-change="validate" phx-submit="save">
  <.input field={@form[:title]} label="Title" />
  <.input field={@form[:body]} type="textarea" label="Body" />
  <:actions>
    <.button>Save</.button>
  </:actions>
</.form>
```

```elixir
@impl true
def mount(_params, _session, socket) do
  changeset = Post.changeset(%Post{}, %{})
  {:ok, assign(socket, form: to_form(changeset))}
end

@impl true
def handle_event("validate", %{"post" => params}, socket) do
  changeset =
    %Post{}
    |> Post.changeset(params)
    |> Map.put(:action, :validate)

  {:noreply, assign(socket, form: to_form(changeset))}
end
```

## Error Handling

Handle errors in handle_event to prevent LiveView crashes — assign errors to the socket instead of letting the process crash.

```elixir
@impl true
def handle_event("save", params, socket) do
  case save_record(params) do
    {:ok, record} ->
      socket =
        socket
        |> put_flash(:info, "Saved successfully")
        |> assign(:record, record)

      {:noreply, socket}

    {:error, %Ecto.Changeset{} = changeset} ->
      socket =
        socket
        |> put_flash(:error, "Please correct the errors")
        |> assign(:changeset, changeset)

      {:noreply, socket}

    {:error, reason} ->
      socket = put_flash(socket, :error, "An error occurred: #{reason}")
      {:noreply, socket}
  end
end
```

> Real-time updates: see the **phoenix-pubsub-patterns** skill.

## Testing

When writing LiveView tests, invoke `elixir-phoenix-guide:testing-essentials` before writing any `_test.exs` file.

## Common Lifecycle Mistakes

Mistakes 1 (uninitialized assigns) and 2 (subscribing without `connected?`) are covered by
rules 2 and 3 above and the Two-Phase Rendering section. One more pitfall isn't covered by
either rule:

### ❌ Expensive Operations in Both Phases

```elixir
@impl true
def mount(_params, _session, socket) do
  # BAD - Runs expensive query twice (static + connected)
  data = run_expensive_query()
  {:ok, assign(socket, :data, data)}
end
```

### ✅ Fix: Defer to connected phase

```elixir
@impl true
def mount(_params, _session, socket) do
  socket =
    if connected?(socket) do
      # Only run when connected
      assign(socket, :data, run_expensive_query())
    else
      # Placeholder for static render
      assign(socket, :data, [])
    end

  {:ok, socket}
end
```

## Lifecycle Flow

```
1. HTTP Request arrives
   ↓
2. mount/3 called (connected? = false)
   ↓
3. handle_params/3 called (connected? = false)
   ↓
4. render/1 called (STATIC HTML generated)
   ↓
5. HTML sent to browser
   ↓
6. Browser connects WebSocket
   ↓
7. mount/3 called AGAIN (connected? = true)
   ↓
8. handle_params/3 called AGAIN (connected? = true)
   ↓
9. render/1 called (sent over WebSocket)
   ↓
10. LiveView now active and reactive
```

## Quick Reference

### Safe Patterns

```elixir
# ✅ Initialize in mount
assign(socket, :key, default_value)

# ✅ Use Map.get for optional
Map.get(socket.assigns, :key, default)

# ✅ Check connected for side effects
if connected?(socket), do: subscribe()

# ✅ Pattern match with fallback
def helper(%{name: name}), do: name
def helper(_), do: "default"

# ✅ Add @impl true
@impl true
def mount(...), do: ...
```

### Unsafe Patterns

```elixir
# ❌ Direct access without initialization
socket.assigns.key

# ❌ Subscribe without checking
Phoenix.PubSub.subscribe(...)

# ❌ Expensive ops in both phases
mount(...) do
  data = expensive_query()
end

# ❌ Missing @impl true
def mount(...), do: ...
```
