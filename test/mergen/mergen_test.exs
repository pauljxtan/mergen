defmodule MergenTest do
  use Mergen.DataCase

  alias Mergen.Items
  alias Mergen.Items.Item
  alias Mergen.Repo

  @sample_attrs_1 %{
    prompt: "The answer to life, the universe, and everything",
    answer: "Forty-two",
    level: 5,
    last_reviewed: nil
  }
  @sample_attrs_2 %{prompt: "6 * 7 = _", answer: "42", level: 0, last_reviewed: nil}
  @sample_attrs_3 %{
    prompt: "Gravitational acceleration in m/s",
    answer: "9.8",
    level: 0,
    last_reviewed: nil
  }

  describe "answer submission" do
    test "increments or decrements level based on answer correctness" do
      {:ok, item} = @sample_attrs_1 |> Map.put(:level, 0) |> Items.create()

      assert {:ok, true, %Item{level: 1}} = Mergen.submit_answer(item.id, item.answer)
      assert {:ok, true, %Item{level: 2}} = Mergen.submit_answer(item.id, item.answer)
      assert {:ok, false, %Item{level: 1}} = Mergen.submit_answer(item.id, "Forty-three")
    end
  end

  describe "lessons and review scheduling" do
    test "gets randomized lesson queue" do
      {:ok, _} = @sample_attrs_1 |> Map.put(:level, 0) |> Items.create()
      {:ok, _} = @sample_attrs_2 |> Map.put(:level, 0) |> Items.create()

      lessons = Mergen.randomized_lesson_queue()

      assert length(lessons) == 2

      assert Enum.any?(lessons, fn %{prompt: prompt, answer: answer} ->
               prompt == @sample_attrs_1.prompt and answer == @sample_attrs_1.answer
             end)

      assert Enum.any?(lessons, fn %{prompt: prompt, answer: answer} ->
               prompt == @sample_attrs_2.prompt and answer == @sample_attrs_2.answer
             end)
    end

    test "gets randomized review queue" do
      {:ok, _} = @sample_attrs_1 |> Map.put(:level, 1) |> Items.create()
      {:ok, _} = @sample_attrs_2 |> Map.put(:level, 2) |> Items.create()

      reviews = Mergen.randomized_review_queue()

      assert length(reviews) == 2

      assert Enum.any?(reviews, fn %{prompt: prompt, answer: answer} ->
               prompt == @sample_attrs_1.prompt and answer == @sample_attrs_1.answer
             end)

      assert Enum.any?(reviews, fn %{prompt: prompt, answer: answer} ->
               prompt == @sample_attrs_2.prompt and answer == @sample_attrs_2.answer
             end)
    end

    test "detects if items are due for lessons or reviews" do
      {:ok, item1} = @sample_attrs_1 |> Items.create()
      {:ok, item2} = @sample_attrs_2 |> Map.put(:level, 10) |> Items.create()
      {:ok, item3} = @sample_attrs_3 |> Items.create()

      yesterday = NaiveDateTime.utc_now() |> NaiveDateTime.add(-100_000)
      {:ok, item2} = item2 |> Items.update(%{last_reviewed: yesterday})

      refute Mergen.due_for_lesson?(item1)
      refute Mergen.due_for_lesson?(item2)
      assert Mergen.due_for_lesson?(item3)
      assert Mergen.due_for_review?(item1)
      refute Mergen.due_for_review?(item2)
      refute Mergen.due_for_review?(item3)

      {:ok, item1} = item1 |> Items.update(%{last_reviewed: yesterday})
      {:ok, item3} = item3 |> Items.update(%{last_reviewed: yesterday})

      refute Mergen.due_for_lesson?(item1)
      refute Mergen.due_for_lesson?(item2)
      refute Mergen.due_for_lesson?(item3)
      refute Mergen.due_for_review?(item1)
      refute Mergen.due_for_review?(item2)
      assert Mergen.due_for_review?(item3)

      # Mergen.update(item1.id, level: 1, last_reviewed: yesterday)
      # Mergen.update(item3.id, level: 10, last_reviewed: yesterday)

      # assert [item1] = Mergen.randomized_review_queue()
      # assert item1.prompt == prompt1
    end
  end

  describe "importing and exporting" do
    test "exports to and imports from a JSON file of items" do
      {:ok, _} = @sample_attrs_1 |> Items.create()
      {:ok, _} = @sample_attrs_2 |> Items.create()

      assert {:ok, 2, filepath} = Mergen.export_json()
      assert File.exists?(filepath)

      Repo.delete_all(Item)

      {:ok, results} = Mergen.import_json(filepath)

      assert results
             |> Enum.any?(fn {:ok, %{prompt: prompt, answer: answer}} ->
               prompt == @sample_attrs_1.prompt and answer == @sample_attrs_1.answer
             end)

      assert results
             |> Enum.any?(fn {:ok, %{prompt: prompt, answer: answer}} ->
               prompt == @sample_attrs_2.prompt and answer == @sample_attrs_2.answer
             end)

      File.rm!(filepath)
    end
  end
end
