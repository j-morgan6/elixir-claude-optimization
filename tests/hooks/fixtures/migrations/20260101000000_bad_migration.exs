defmodule Repo.Migrations.Bad do
  use Ecto.Migration
  def change do
    create table(:comments) do
      add :post_id, references(:posts)
    end
  end
end
