# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Mergen.Repo.insert!(%Mergen.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Mergen.Items.Item
alias Mergen.Repo

%Item{}
|> Item.changeset(%{
  prompt: "The answer to life, the universe, and everything",
  answer: "Forty-two",
  level: 5
})
|> Repo.insert!()
