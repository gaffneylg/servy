defmodule PledgeServerTest do

  use ExUnit.Case

  alias Servy.PledgeServer

  test "confirms cache only stores 3 amounts" do
    pid = PledgeServer.start

    PledgeServer.create_pledge("timmy", 30)
    PledgeServer.create_pledge("jimmy", 40)
    PledgeServer.create_pledge("kimmy", 50)
    PledgeServer.create_pledge("zimmy", 60)

    recent_pledges = PledgeServer.recent_pledges()

    expected_cache_total = 150

    returned_cache_total = PledgeServer.total_pledged()

    assert expected_cache_total == returned_cache_total

    assert 3 == length(recent_pledges)
  end

end
