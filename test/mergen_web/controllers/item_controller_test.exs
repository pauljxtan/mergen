defmodule MergenWeb.ItemControllerTest do
  use MergenWeb.ConnCase

  alias Mergen.Items

  @create_attrs %{
    answer: "some answer",
    last_reviewed: ~N[2010-04-17 14:00:00.000000],
    level: 42,
    prompt: "some prompt"
  }
  @update_attrs %{
    answer: "some updated answer",
    last_reviewed: ~N[2011-05-18 15:01:01.000000],
    level: 43,
    prompt: "some updated prompt"
  }
  @invalid_attrs %{answer: nil, last_reviewed: nil, level: nil, prompt: nil}

  def fixture(:item) do
    {:ok, item} = Items.create(@create_attrs)
    item
  end

  describe "index" do
    test "lists all items", %{conn: conn} do
      conn = get(conn, item_path(conn, :index))
      assert html_response(conn, 200) =~ "All items"
    end
  end

  describe "new item" do
    test "renders form", %{conn: conn} do
      conn = get(conn, item_path(conn, :new))
      assert html_response(conn, 200) =~ "New"
    end
  end

  describe "create item" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, item_path(conn, :create), item: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == item_path(conn, :show, id)

      conn = get(conn, item_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Details"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, item_path(conn, :create), item: @invalid_attrs)
      assert html_response(conn, 200) =~ "New"
    end
  end

  describe "edit item" do
    setup [:create]

    test "renders form for editing chosen item", %{conn: conn, item: item} do
      conn = get(conn, item_path(conn, :edit, item))
      assert html_response(conn, 200) =~ "Edit"
    end
  end

  describe "update item" do
    setup [:create]

    test "redirects when data is valid", %{conn: conn, item: item} do
      conn = put(conn, item_path(conn, :update, item), item: @update_attrs)
      assert redirected_to(conn) == item_path(conn, :show, item)

      conn = get(conn, item_path(conn, :show, item))
      assert html_response(conn, 200) =~ "some updated answer"
    end

    test "renders errors when data is invalid", %{conn: conn, item: item} do
      conn = put(conn, item_path(conn, :update, item), item: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit"
    end
  end

  describe "delete item" do
    setup [:create]

    test "deletes chosen item", %{conn: conn, item: item} do
      conn = delete(conn, item_path(conn, :delete, item))
      assert redirected_to(conn) == item_path(conn, :index)

      assert_error_sent(404, fn ->
        get(conn, item_path(conn, :show, item))
      end)
    end
  end

  defp create(_) do
    item = fixture(:item)
    {:ok, item: item}
  end
end
