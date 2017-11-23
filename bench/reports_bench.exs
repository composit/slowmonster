defmodule ReportsBench do
  import Mix.Ecto
  import Tzdata.App

  use Benchfella

  setup_all do
    ensure_started(Slowmonster.Repo, [])
    Application.ensure_all_started(:timex)

    Slowmonster.Seeder.seed

    end_time = Timex.now
    start_time = Timex.shift(end_time, days: -365)

    {:ok, start_time: start_time, end_time: end_time}
  end

  teardown_all _ do
    # how do I gracefully stop the applications?
  end

  bench "daily report" do
    [start_time: start_time, end_time: end_time] = bench_context
    Slowmonster.Reports.report %{type: "daily", user_id: 1, ticket_ids: [1], start_time: start_time, end_time: end_time}
  end
end
