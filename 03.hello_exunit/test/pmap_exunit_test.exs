defmodule PMapExunitTest do
  use ExUnit.Case, async: false

  import HelloExunit.PMap
  import ExUnit.CaptureLog

  setup _context do
    {:ok, [in_list: [1,2,3],
           out_list: [2,4,6],
           fn: fn x -> x * 2 end]}
  end

  test "pmap maps a list", context do
    assert context[:out_list] == pmap(context[:in_list], context[:fn])
  end

  test "pmap spawns async tasks", context do
    pmap(context[:in_list], context[:fn])

    assert_received({pid1, :ok})
    assert_received({pid2, :ok})
    assert_received({pid3, :ok})

    refute pid1 == pid2
    refute pid1 == pid3
    refute pid2 == pid3
  end

  test "pmap logs a completion debug log message", context do
    assert capture_log(fn ->
      pmap(context[:in_list], context[:fn])
    end) =~ "[debug] pmap started with input: " <> inspect(context[:in_list])
  end
end
