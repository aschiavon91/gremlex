import Config

config :gremlex,
  host: {:system, "GREMLEX_HOST", "127.0.0.1"},
  port: 8182,
  path: "/gremlin",
  pool_size: 10,
  secure: false
