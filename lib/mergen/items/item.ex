defmodule Mergen.Items.Item do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "items" do
    field(:answer, :string)
    field(:last_reviewed, :naive_datetime, default: nil)
    field(:level, :integer, default: 0)
    field(:prompt, :string)

    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:prompt, :answer, :level, :last_reviewed])
    |> validate_required([:prompt, :answer])
  end
end
