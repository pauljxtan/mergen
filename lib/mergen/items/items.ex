defmodule Mergen.Items do
  @moduledoc """
  The context for study items.
  """
  import Ecto.Query, warn: false
  alias Mergen.Items.Item
  alias Mergen.Repo

  @never "Never"

  @doc """
  Returns all items.
  """
  def all do
    Repo.all(Item)
  end

  @doc """
  Gets an item by id.

  Raises `Ecto.NoResultsError` if the item does not exist.
  """
  def get!(id), do: Repo.get!(Item, id)

  @doc """
  Creates an item with the given attributes.
  """
  def create(attrs \\ %{}) do
    %Item{}
    |> Item.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates an item with the given attributes.
  """
  def update(%Item{} = item, attrs) do
    item
    |> Item.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes an item.

  ## Examples
  """
  def delete(%Item{} = item) do
    Repo.delete(item)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking item changes.
  """
  def change(%Item{} = item) do
    Item.changeset(item, %{})
  end

  @doc """
  Encodes a list of items to JSON.
  """
  def encode(items) do
    items =
      items
      |> Enum.map(fn %{prompt: prompt, answer: answer, level: level, last_reviewed: last_reviewed} ->
        last_reviewed = if last_reviewed == nil, do: @never, else: last_reviewed
        %{prompt: prompt, answer: answer, level: level, last_reviewed: last_reviewed}
      end)

    {:ok, Poison.encode!(items)}
  end

  @doc """
  Decodes a list of items from JSON.
  """
  def decode(json) do
    items =
      Poison.decode!(json)
      # Convert keys to atoms
      |> Enum.map(fn item ->
        item |> Map.new(fn {key, value} -> {String.to_atom(key), value} end)
      end)
      # Convert string datetimes to NaiveDateTimes
      |> Enum.map(fn item ->
        last_reviewed =
          if item.last_reviewed == @never,
            do: nil,
            else: NaiveDateTime.from_iso8601!(item.last_reviewed)

        %{item | last_reviewed: last_reviewed}
      end)

    {:ok, items}
  end
end
