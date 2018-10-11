defmodule MergenWeb.SharedView do
  @moduledoc false
  use MergenWeb, :view

  def num_lessons(), do: Mergen.randomized_lesson_queue() |> length()
  def num_reviews(), do: Mergen.randomized_review_queue() |> length()
end
