# Ecto Conventions and Best Practices

## Schema Design

### Basic Schema Structure

```elixir
defmodule MyApp.Media.Image do
  use Ecto.Schema
  import Ecto.Changeset

  schema "images" do
    field :title, :string
    field :description, :string
    field :filename, :string
    field :file_path, :string
    field :content_type, :string
    field :file_size, :integer

    belongs_to :folder, MyApp.Media.Folder

    timestamps()
  end

  @doc false
  def changeset(image, attrs) do
    image
    |> cast(attrs, [:title, :description, :filename, :file_path, :content_type, :file_size, :folder_id])
    |> validate_required([:title, :filename, :file_path, :content_type, :file_size])
    |> validate_length(:title, min: 1, max: 255)
    |> validate_number(:file_size, greater_than: 0)
    |> foreign_key_constraint(:folder_id)
  end
end
```

### Field Types

Common field types:
- `:string` - Variable length text (VARCHAR)
- `:text` - Long text (TEXT)
- `:integer` - Whole numbers
- `:float` - Decimal numbers
- `:boolean` - true/false
- `:date` - Date only
- `:time` - Time only
- `:naive_datetime` - DateTime without timezone
- `:utc_datetime` - DateTime with UTC timezone
- `:binary` - Binary data
- `:map` - JSONB in Postgres

### Associations

```elixir
# One-to-many
belongs_to :folder, MyApp.Media.Folder
has_many :images, MyApp.Media.Image

# Many-to-many
many_to_many :tags, MyApp.Media.Tag, join_through: "images_tags"

# Has one
has_one :profile, MyApp.Accounts.Profile
```

## Changesets

### Basic Changeset Pattern

```elixir
def changeset(struct, attrs) do
  struct
  |> cast(attrs, [:field1, :field2])           # Cast allowed fields
  |> validate_required([:field1])              # Required fields
  |> validate_length(:field1, min: 1, max: 255) # Length validation
  |> unique_constraint(:field1)                # Unique constraint
end
```

### Validation Functions

```elixir
# Required fields
|> validate_required([:title, :content])

# Length
|> validate_length(:title, min: 1, max: 255)
|> validate_length(:description, min: 10)

# Format (regex)
|> validate_format(:email, ~r/@/)

# Inclusion in list
|> validate_inclusion(:status, ["active", "inactive"])

# Exclusion from list
|> validate_exclusion(:role, ["banned"])

# Number validation
|> validate_number(:age, greater_than: 0, less_than: 150)
|> validate_number(:price, greater_than_or_equal_to: 0)

# Custom validation
|> validate_change(:field, fn :field, value ->
  if valid?(value), do: [], else: [field: "is invalid"]
end)

# Confirmation (password confirmation)
|> validate_confirmation(:password)

# Acceptance (terms of service)
|> validate_acceptance(:terms)
```

### Constraints

Database constraints checked at insert/update:

```elixir
# Unique constraint
|> unique_constraint(:email)
|> unique_constraint(:name, name: :folders_name_index)

# Foreign key constraint
|> foreign_key_constraint(:folder_id)

# Check constraint
|> check_constraint(:price, name: :price_must_be_positive)

# No assoc constraint (prevent orphans)
|> no_assoc_constraint(:images)
```

### Changeset Actions

```elixir
# For validation without save
changeset = Map.put(changeset, :action, :validate)

# For insert
changeset = Map.put(changeset, :action, :insert)

# For update
changeset = Map.put(changeset, :action, :update)
```

## Queries

### Basic Queries

```elixir
import Ecto.Query

# Get all
Repo.all(Image)

# Get by ID
Repo.get(Image, id)
Repo.get!(Image, id)  # Raises if not found

# Get by field
Repo.get_by(Image, title: "Sunset")

# Get first
Repo.one(query)
```

### Building Queries

```elixir
# Where clause
query = from i in Image, where: i.folder_id == ^folder_id

# Multiple conditions
query = from i in Image,
  where: i.folder_id == ^folder_id,
  where: i.file_size > 1000

# Or conditions
query = from i in Image,
  where: i.folder_id == ^folder_id or is_nil(i.folder_id)

# Order by
query = from i in Image, order_by: [desc: i.inserted_at]

# Limit
query = from i in Image, limit: 10

# Offset
query = from i in Image, offset: 10

# Select specific fields
query = from i in Image, select: {i.id, i.title}

# Select map
query = from i in Image, select: %{id: i.id, title: i.title}
```

### Piping Queries

```elixir
Image
|> where([i], i.folder_id == ^folder_id)
|> order_by([i], desc: i.inserted_at)
|> limit(10)
|> Repo.all()
```

### Joins

```elixir
# Inner join
query = from i in Image,
  join: f in assoc(i, :folder),
  where: f.name == "Vacation"

# Left join
query = from i in Image,
  left_join: f in assoc(i, :folder),
  select: {i, f}

# Preload (avoid N+1)
query = from i in Image, preload: [:folder]
```

### Aggregations

```elixir
# Count
Repo.aggregate(Image, :count)
from(i in Image, select: count(i.id)) |> Repo.one()

# Sum
from(i in Image, select: sum(i.file_size)) |> Repo.one()

# Average
from(i in Image, select: avg(i.file_size)) |> Repo.one()

# Group by
from(i in Image,
  group_by: i.folder_id,
  select: {i.folder_id, count(i.id)}
) |> Repo.all()
```

## Repository Operations

### Insert

```elixir
# With changeset
%Image{}
|> Image.changeset(attrs)
|> Repo.insert()

# Returns {:ok, image} or {:error, changeset}

# Bang version (raises on error)
Repo.insert!(changeset)
```

### Update

```elixir
# With changeset
image
|> Image.changeset(attrs)
|> Repo.update()

# Returns {:ok, image} or {:error, changeset}
```

### Delete

```elixir
# Delete struct
Repo.delete(image)

# Delete all matching query
query = from i in Image, where: i.folder_id == ^folder_id
Repo.delete_all(query)
```

### Upsert

```elixir
%Image{}
|> Image.changeset(attrs)
|> Repo.insert(
  on_conflict: {:replace, [:title, :description]},
  conflict_target: :filename
)
```

## Preloading

### Avoid N+1 Queries

```elixir
# Bad - N+1 queries
images = Repo.all(Image)
Enum.each(images, fn image ->
  IO.puts(image.folder.name)  # Query per image!
end)

# Good - Single query with join
images = Repo.all(from i in Image, preload: [:folder])
Enum.each(images, fn image ->
  IO.puts(image.folder.name)
end)
```

### Multiple Preloads

```elixir
# Preload multiple associations
query = from i in Image, preload: [:folder, :tags]

# Nested preload
query = from f in Folder, preload: [images: :tags]

# Preload with custom query
images_query = from i in Image, where: i.file_size > 1000
query = from f in Folder, preload: [images: ^images_query]
```

## Transactions

```elixir
Repo.transaction(fn ->
  case create_folder(attrs) do
    {:ok, folder} ->
      case create_image(folder, image_attrs) do
        {:ok, image} -> image
        {:error, reason} -> Repo.rollback(reason)
      end
    {:error, reason} ->
      Repo.rollback(reason)
  end
end)

# Returns {:ok, result} or {:error, reason}
```

## Context Pattern

Wrap database operations in context functions:

```elixir
defmodule MyApp.Media do
  alias MyApp.Media.{Image, Folder}
  alias MyApp.Repo
  import Ecto.Query

  # List functions
  def list_images do
    Image
    |> order_by(desc: :inserted_at)
    |> preload(:folder)
    |> Repo.all()
  end

  def list_images_by_folder(folder_id) do
    Image
    |> where([i], i.folder_id == ^folder_id)
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  # Get functions
  def get_image!(id), do: Repo.get!(Image, id)

  def get_folder!(id), do: Repo.get!(Folder, id)

  # Create functions
  def create_image(attrs \\ %{}) do
    %Image{}
    |> Image.changeset(attrs)
    |> Repo.insert()
  end

  def create_folder(attrs \\ %{}) do
    %Folder{}
    |> Folder.changeset(attrs)
    |> Repo.insert()
  end

  # Update functions
  def update_image(%Image{} = image, attrs) do
    image
    |> Image.changeset(attrs)
    |> Repo.update()
  end

  # Delete functions
  def delete_image(%Image{} = image) do
    Repo.delete(image)
  end

  # Business logic
  def move_image_to_folder(%Image{} = image, folder_id) do
    update_image(image, %{folder_id: folder_id})
  end
end
```

## Migrations

### Creating Migrations

```bash
mix ecto.gen.migration create_images
```

### Migration Structure

```elixir
defmodule MyApp.Repo.Migrations.CreateImages do
  use Ecto.Migration

  def change do
    create table(:images) do
      add :title, :string, null: false
      add :description, :text
      add :filename, :string, null: false
      add :file_path, :string, null: false
      add :content_type, :string, null: false
      add :file_size, :integer, null: false
      add :folder_id, references(:folders, on_delete: :nilify_all)

      timestamps()
    end

    create index(:images, [:folder_id])
    create index(:images, [:inserted_at])
  end
end
```

### Migration Operations

```elixir
# Add column
alter table(:images) do
  add :priority, :integer, default: 0
end

# Remove column
alter table(:images) do
  remove :old_field
end

# Rename column
rename table(:images), :old_name, to: :new_name

# Add index
create index(:images, [:title])
create unique_index(:folders, [:name])

# Remove index
drop index(:images, [:title])

# Add constraint
create constraint(:images, :file_size_must_be_positive, check: "file_size > 0")
```

## Common Patterns

### Soft Delete

```elixir
schema "images" do
  field :deleted_at, :utc_datetime
  # ...
end

def list_images do
  from(i in Image, where: is_nil(i.deleted_at))
  |> Repo.all()
end

def soft_delete(%Image{} = image) do
  update_image(image, %{deleted_at: DateTime.utc_now()})
end
```

### Ordering with Nulls

```elixir
# Nulls last
from i in Image, order_by: [asc_nulls_last: i.folder_id]

# Nulls first
from i in Image, order_by: [desc_nulls_first: i.priority]
```

### Dynamic Filters

```elixir
def list_images(filters) do
  Image
  |> apply_filters(filters)
  |> Repo.all()
end

defp apply_filters(query, filters) do
  Enum.reduce(filters, query, &apply_filter/2)
end

defp apply_filter({:folder_id, id}, query) do
  where(query, [i], i.folder_id == ^id)
end

defp apply_filter({:search, term}, query) do
  where(query, [i], ilike(i.title, ^"%#{term}%"))
end

defp apply_filter(_, query), do: query
```
