defmodule Mergen.ItemsTest do
  use Mergen.DataCase

  alias Mergen.Items
  alias Mergen.Items.Item

  describe "basic CRUD" do
    @valid_attrs %{
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

    def item_fixture(attrs \\ %{}) do
      {:ok, item} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Items.create()

      item
    end

    test "all/0 returns all items" do
      item = item_fixture()
      assert Items.all() == [item]
    end

    test "get!/1 returns the item with given id" do
      item = item_fixture()
      assert Items.get!(item.id) == item
    end

    test "create/1 with valid data creates a item" do
      assert {:ok, %Item{} = item} = Items.create(@valid_attrs)
      assert item.answer == "some answer"
      assert item.last_reviewed == ~N[2010-04-17 14:00:00.000000]
      assert item.level == 42
      assert item.prompt == "some prompt"
    end

    test "create/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Items.create(@invalid_attrs)
    end

    test "update/2 with valid data updates the item" do
      item = item_fixture()
      assert {:ok, item} = Items.update(item, @update_attrs)
      assert %Item{} = item
      assert item.answer == "some updated answer"
      assert item.last_reviewed == ~N[2011-05-18 15:01:01.000000]
      assert item.level == 43
      assert item.prompt == "some updated prompt"
    end

    test "update/2 with invalid data returns error changeset" do
      item = item_fixture()
      assert {:error, %Ecto.Changeset{}} = Items.update(item, @invalid_attrs)
      assert item == Items.get!(item.id)
    end

    test "delete/1 deletes the item" do
      item = item_fixture()
      assert {:ok, %Item{}} = Items.delete(item)
      assert_raise Ecto.NoResultsError, fn -> Items.get!(item.id) end
    end

    test "change/1 returns a item changeset" do
      item = item_fixture()
      assert %Ecto.Changeset{} = Items.change(item)
    end
  end
end
