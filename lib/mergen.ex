defmodule Mergen do
  @moduledoc """
  The high-level API.
  """
  alias Mergen.Items
  alias Mergen.Items.Item

  def randomized_lesson_queue(), do: randomized_queue(:lesson)
  def randomized_review_queue(), do: randomized_queue(:review)

  defp randomized_queue(type) do
    filter_func =
      case type do
        :lesson -> &due_for_lesson?(&1)
        :review -> &due_for_review?(&1)
      end

    Items.all() |> Enum.filter(filter_func) |> Enum.shuffle()
  end

  def due_for_lesson?(item), do: item_status(item) == :lesson
  def due_for_review?(item), do: item_status(item) == :review

  defp item_status(%{:last_reviewed => nil, :level => 0}), do: :lesson
  defp item_status(%{:last_reviewed => nil}), do: :review

  defp item_status(%{:last_reviewed => last_reviewed, :level => level}) do
    now = NaiveDateTime.utc_now()

    days_since_review =
      NaiveDateTime.to_date(now)
      |> Date.diff(NaiveDateTime.to_date(last_reviewed))

    hours_since_review = days_since_review * 24 + (now.hour - last_reviewed.hour)

    if hours_since_review > review_interval_hours(level),
      do: :review,
      else: :wait
  end

  defp review_interval_hours(level),
    do: 2 |> :math.pow(level + 1) |> trunc()

  @spec submit_answer(integer, String.t()) :: Item.t()
  def submit_answer(item_id, answer) do
    item = Items.get!(item_id)

    correct = item |> answer_correct?(answer)
    new_level = if correct, do: item.level + 1, else: item.level - 1
    new_last_reviewed = NaiveDateTime.utc_now()

    {:ok, item} = item |> Items.update(%{level: new_level, last_reviewed: new_last_reviewed})
    {:ok, correct, item}
  end

  defp answer_correct?(item, answer, jaro_threshold \\ 0.9) do
    given = answer |> String.trim() |> String.downcase()
    actual = item.answer |> String.trim() |> String.downcase()
    String.jaro_distance(given, actual) >= jaro_threshold
  end

  @doc """
  Exports all items in the database to a JSON file.

  If successful, returns the number of exported items and the export path.
  Otherwise, returns an error string.
  """
  @spec export_json(String.t()) :: {:ok, integer, String.t()} | {:error, String.t()}
  def export_json(filepath \\ "") do
    items = Items.all()
    {:ok, json} = Items.all() |> Items.encode()

    filepath =
      if filepath == "",
        do: "exports/export_#{timestamp_now()}.json",
        else: filepath

    parent = Path.dirname(filepath)
    :ok = ensure_path_exists(parent)

    case File.write(filepath, json) do
      :ok -> {:ok, length(items), filepath}
      {:error, reason} -> {:error, reason}
    end
  end

  defp timestamp_now() do
    now = NaiveDateTime.utc_now()

    year = now.year |> Integer.to_string() |> String.slice(2, 4)
    month = now.month |> Integer.to_string() |> String.pad_leading(2, "0")
    day = now.day |> Integer.to_string() |> String.pad_leading(2, "0")
    hour = now.hour |> Integer.to_string() |> String.pad_leading(2, "0")
    minute = now.minute |> Integer.to_string() |> String.pad_leading(2, "0")
    second = now.second |> Integer.to_string() |> String.pad_leading(2, "0")

    "#{year}#{month}#{day}#{hour}#{minute}#{second}"
  end

  defp ensure_path_exists(path),
    do: if(File.exists?(path), do: :ok, else: File.mkdir_p!(path))

  @doc """
  Imports a list of items from a JSON file into the database.

  Currently does not check for duplicates, and last_reviewed values are ignored.
  """
  @spec import_json(String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def import_json(filepath) do
    case File.read(filepath) do
      {:ok, json} ->
        {:ok, items} = Items.decode(json)

        results = items |> Enum.map(fn item -> Items.create(item) end)

        # TODO: Check individual insert results for errors
        {:ok, results}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
