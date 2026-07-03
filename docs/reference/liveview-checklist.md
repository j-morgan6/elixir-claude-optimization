# LiveView Development Checklist

Use this checklist when implementing or reviewing LiveView modules.

## Module Setup

- [ ] Use correct LiveView module: `use MyAppWeb, :live_view`
- [ ] Add `@impl true` before all callback functions
- [ ] Import necessary aliases at top of module
- [ ] Define module documentation with `@moduledoc`

```elixir
defmodule MyAppWeb.GalleryLive do
  use MyAppWeb, :live_view

  alias MyApp.Media
  alias MyApp.Media.{Image, Folder}

  @moduledoc """
  LiveView for managing image gallery.
  """
end
```

## Mount Implementation

- [ ] Handle both disconnected and connected states
- [ ] Check `connected?(socket)` for side effects
- [ ] Subscribe to PubSub topics only when connected
- [ ] Initialize all socket assigns
- [ ] Return proper tuple: `{:ok, socket}` or `{:ok, socket, temporary_assigns: [...]}`

```elixir
@impl true
def mount(_params, _session, socket) do
  if connected?(socket) do
    Phoenix.PubSub.subscribe(MyApp.PubSub, "images")
  end

  socket =
    socket
    |> assign(:images, Media.list_images())
    |> assign(:folders, Media.list_folders())
    |> assign(:selected_folder, nil)

  {:ok, socket}
end
```

## Handle Params

- [ ] Implement `handle_params/3` if route has parameters
- [ ] Always return `{:noreply, socket}`
- [ ] Load data based on URL params
- [ ] Add `@impl true` attribute

```elixir
@impl true
def handle_params(%{"id" => folder_id}, _uri, socket) do
  folder = Media.get_folder!(folder_id)
  images = Media.list_images_by_folder(folder_id)

  socket =
    socket
    |> assign(:selected_folder, folder)
    |> assign(:images, images)

  {:noreply, socket}
end

@impl true
def handle_params(_params, _uri, socket) do
  {:noreply, assign(socket, :selected_folder, nil)}
end
```

## Handle Event

- [ ] Add `@impl true` attribute
- [ ] Pattern match on event name
- [ ] Extract params using pattern matching
- [ ] Always return `{:noreply, socket}`
- [ ] Handle errors gracefully with flash messages
- [ ] Update relevant socket assigns

```elixir
@impl true
def handle_event("delete_image", %{"id" => id}, socket) do
  image = Media.get_image!(id)

  case Media.delete_image(image) do
    {:ok, _} ->
      socket =
        socket
        |> put_flash(:info, "Image deleted")
        |> update(:images, fn images ->
          Enum.reject(images, &(&1.id == id))
        end)

      {:noreply, socket}

    {:error, _} ->
      {:noreply, put_flash(socket, :error, "Failed to delete")}
  end
end
```

## Handle Info

- [ ] Add `@impl true` attribute
- [ ] Pattern match on message structure
- [ ] Handle PubSub broadcasts
- [ ] Update socket state based on message
- [ ] Always return `{:noreply, socket}`

```elixir
@impl true
def handle_info({:image_created, image}, socket) do
  {:noreply, update(socket, :images, fn images -> [image | images] end)}
end

@impl true
def handle_info({:image_deleted, image_id}, socket) do
  {:noreply, update(socket, :images, fn images ->
    Enum.reject(images, &(&1.id == image_id))
  end)}
end
```

## File Uploads

- [ ] Configure upload in mount with `allow_upload/3`
- [ ] Set `accept`, `max_entries`, `max_file_size`
- [ ] Implement "validate" event for live validation
- [ ] Implement "save" event to consume uploads
- [ ] Use `consume_uploaded_entries/3` to process files
- [ ] Handle upload errors in template

```elixir
@impl true
def mount(_params, _session, socket) do
  socket =
    socket
    |> assign(:uploaded_files, [])
    |> allow_upload(:image,
        accept: ~w(.jpg .jpeg .png .gif),
        max_entries: 5,
        max_file_size: 10_000_000
      )

  {:ok, socket}
end

@impl true
def handle_event("validate", _params, socket) do
  {:noreply, socket}
end

@impl true
def handle_event("save", _params, socket) do
  uploaded_files =
    consume_uploaded_entries(socket, :image, fn %{path: path}, entry ->
      dest = Path.join(upload_dir(), entry.client_name)
      File.cp!(path, dest)

      Media.create_image(%{
        filename: entry.client_name,
        file_path: dest,
        content_type: entry.client_type,
        file_size: entry.client_size
      })
    end)

  {:noreply, update(socket, :images, &(&1 ++ uploaded_files))}
end
```

## Templates

- [ ] Use HEEx syntax `~H"""`
- [ ] Bind events with `phx-click`, `phx-submit`, etc.
- [ ] Use components with `<.component_name />`
- [ ] Handle upload errors with `@uploads.image.errors`
- [ ] Show loading states during operations

```heex
<.simple_form for={@form} phx-change="validate" phx-submit="save">
  <.input field={@form[:title]} label="Title" />

  <div phx-drop-target={@uploads.image.ref}>
    <.live_file_input upload={@uploads.image} />
  </div>

  <%= for entry <- @uploads.image.entries do %>
    <div>
      <.live_img_preview entry={entry} />
      <progress value={entry.progress} max="100"><%= entry.progress %>%</progress>
    </div>
  <% end %>

  <:actions>
    <.button phx-disable-with="Uploading...">Upload</.button>
  </:actions>
</.simple_form>
```

## Navigation

- [ ] Use `push_navigate/2` for different LiveViews
- [ ] Use `push_patch/2` for same LiveView with different params
- [ ] Use `~p` sigil for paths
- [ ] Handle navigation in event handlers

```elixir
# Navigate to different LiveView
{:noreply, push_navigate(socket, to: ~p"/settings")}

# Patch URL (same LiveView)
{:noreply, push_patch(socket, to: ~p"/gallery/#{folder_id}")}
```

## Flash Messages

- [ ] Use `put_flash/3` for user feedback
- [ ] Clear flash with `clear_flash/2` when needed
- [ ] Use `:info` for success, `:error` for failures

```elixir
socket = put_flash(socket, :info, "Image uploaded successfully")
socket = put_flash(socket, :error, "Upload failed")
```

## Testing

- [ ] Test mount behavior
- [ ] Test events with `render_click/2`, `render_submit/2`
- [ ] Test file uploads with `file_input/4` and `render_upload/2`
- [ ] Verify assigns are updated correctly
- [ ] Check flash messages appear

```elixir
test "uploads and displays image", %{conn: conn} do
  {:ok, lv, _html} = live(conn, "/gallery")

  image = file_input(lv, "#upload-form", :image, [
    %{name: "test.png", content: File.read!("test/fixtures/test.png")}
  ])

  assert render_upload(image, "test.png") =~ "100%"

  lv
  |> form("#upload-form")
  |> render_submit()

  assert has_element?(lv, "img[alt='test.png']")
end
```

## Performance

- [ ] Use streams for large lists: `stream(socket, :images, images)`
- [ ] Use temporary assigns for data that doesn't need to persist
- [ ] Debounce frequent events (search, etc.)
- [ ] Minimize data in socket assigns
- [ ] Preload associations to avoid N+1 queries

## Common Pitfalls

❌ **Don't** perform expensive operations in render
❌ **Don't** forget to add `@impl true`
❌ **Don't** subscribe to PubSub when not connected
❌ **Don't** modify socket after `push_navigate/2`
❌ **Don't** use `socket.assigns` in templates (use `@assign_name`)

✅ **Do** handle both connected and disconnected mount
✅ **Do** use pattern matching in event handlers
✅ **Do** return proper tuples from callbacks
✅ **Do** validate uploads before processing
✅ **Do** provide user feedback with flash messages
