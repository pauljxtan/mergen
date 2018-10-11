defmodule MergenWeb.PageController do
  @moduledoc false
  use MergenWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def lessons(conn, _params) do
    render(conn, "lessons.html")
  end

  def reviews(conn, _params) do
    render(conn, "reviews.html")
  end
end
