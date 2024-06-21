defmodule CoPlanHub.Repo do
  use Ecto.Repo,
    otp_app: :co_plan_hub,
    adapter: Ecto.Adapters.Postgres
end
