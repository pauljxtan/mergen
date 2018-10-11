defmodule MergenWeb.ItemController do
  @moduledoc false
  use MergenWeb, :controller

  alias Mergen.Items
  alias Mergen.Items.Item

  def index(conn, _params) do
    items =
      Items.all()
      |> Enum.map(fn item ->
        if item.last_reviewed == nil, do: Map.put(item, :last_reviewed, "Never"), else: item
      end)

    render(conn, "index.html", items: items)
  end

  def new(conn, _params) do
    changeset = Items.change(%Item{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"item" => item_params}) do
    case Items.create(item_params) do
      {:ok, item} ->
        conn
        |> put_flash(:info, "Item created successfully.")
        |> redirect(to: item_path(conn, :show, item))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    item = Items.get!(id)
    render(conn, "show.html", item: item)
  end

  def edit(conn, %{"id" => id}) do
    item = Items.get!(id)
    changeset = Items.change(item)
    render(conn, "edit.html", item: item, changeset: changeset)
  end

  def update(conn, %{"id" => id, "item" => item_params}) do
    item = Items.get!(id)
    # The user shouldn't be able to modify last reviewed times
    item_params = item_params |> Map.delete(:last_reviewed)

    case Items.update(item, item_params) do
      {:ok, item} ->
        conn
        |> put_flash(:info, "Item updated successfully.")
        |> redirect(to: item_path(conn, :show, item))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", item: item, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    item = Items.get!(id)
    {:ok, _item} = Items.delete(item)

    conn
    |> put_flash(:info, "Item deleted successfully.")
    |> redirect(to: item_path(conn, :index))
  end
end
