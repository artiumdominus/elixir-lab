defmodule HelloExunit.PMap do
  require Logger

  def pmap(collection, function) do
    caller = self()
    Logger.debug("pmap started with input: #{inspect(collection)}")

    collection
    |> Enum.map(fn x ->
      spawn_link(fn ->
        send caller, {self(), function.(x)}
        send caller, {self(), :ok}
      end)
    end)
    |> Enum.map(fn task_pid -> (receive do {^task_pid, result} -> result end) end)
  end
end
