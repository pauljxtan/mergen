defmodule Mergen.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items) do
      add(:prompt, :string)
      add(:answer, :string)
      add(:level, :integer, default: 0)
      add(:last_reviewed, :naive_datetime, default: nil)

      timestamps()
    end
  end
end
