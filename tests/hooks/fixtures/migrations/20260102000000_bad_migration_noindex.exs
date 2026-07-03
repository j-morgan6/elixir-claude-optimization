defmodule Repo.Migrations.BadNoIndex do
  use Ecto.Migration
  def change do
    create table(:comments) do
      add :post_id, references(:posts, on_delete: :delete_all)
    end
  end
end
