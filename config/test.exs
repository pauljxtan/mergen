use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :mergen, MergenWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :mergen, Mergen.Repo,
  adapter: Sqlite.Ecto2,
  database: "mergen_test.sqlite",
  pool: Ecto.Adapters.SQL.Sandbox
