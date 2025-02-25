defmodule Oban.ConfigTest do
  use ExUnit.Case, async: true

  alias Oban.Config

  describe "start_link/1" do
    test "a config struct is stored for retreival" do
      conf = Config.new(repo: Fake.Repo)

      {:ok, pid} = Config.start_link(conf: conf)

      assert %Config{} = Config.get(pid)
    end
  end

  describe "new/1" do
    test ":node is validated as a binary" do
      assert_raise ArgumentError, fn -> Config.new(repo: Fake, node: nil) end
      assert_raise ArgumentError, fn -> Config.new(repo: Fake, node: '') end
      assert_raise ArgumentError, fn -> Config.new(repo: Fake, node: "") end
      assert_raise ArgumentError, fn -> Config.new(repo: Fake, node: MyNode) end

      assert %Config{} = Config.new(repo: Fake, node: "MyNode")
    end

    test ":poll_interval is validated as an integer" do
      assert_raise ArgumentError, fn -> Config.new(repo: Fake, poll_interval: -1) end
      assert_raise ArgumentError, fn -> Config.new(repo: Fake, poll_interval: 0) end
      assert_raise ArgumentError, fn -> Config.new(repo: Fake, poll_interval: "5") end
      assert_raise ArgumentError, fn -> Config.new(repo: Fake, poll_interval: 1.0) end

      assert %Config{} = Config.new(repo: Fake, poll_interval: 10)
    end

    test ":prune is validated as disabled or a max* option" do
      assert_raise ArgumentError, fn -> Config.new(repo: Fake, prune: :unknown) end
      assert_raise ArgumentError, fn -> Config.new(repo: Fake, prune: 5) end
      assert_raise ArgumentError, fn -> Config.new(repo: Fake, prune: "disabled") end
      assert_raise ArgumentError, fn -> Config.new(repo: Fake, prune: {:maxlen, "1"}) end
      assert_raise ArgumentError, fn -> Config.new(repo: Fake, prune: {:maxlen, -5}) end
      assert_raise ArgumentError, fn -> Config.new(repo: Fake, prune: {:maxage, "1"}) end
      assert_raise ArgumentError, fn -> Config.new(repo: Fake, prune: {:maxage, -5}) end

      assert %Config{} = Config.new(repo: Fake, prune: :disabled)
      assert %Config{} = Config.new(repo: Fake, prune: {:maxlen, 10})
      assert %Config{} = Config.new(repo: Fake, prune: {:maxage, 10})
    end

    test ":prune_interval is validated as a positive integer" do
      assert_raise ArgumentError, fn -> Config.new(repo: Fake, prune_interval: -1) end
      assert_raise ArgumentError, fn -> Config.new(repo: Fake, prune_interval: 0) end
      assert_raise ArgumentError, fn -> Config.new(repo: Fake, prune_interval: "5") end
      assert_raise ArgumentError, fn -> Config.new(repo: Fake, prune_interval: 1.0) end

      assert %Config{} = Config.new(repo: Fake, prune_interval: 500)
    end

    test ":prune_limit is validated as a positive integer" do
      assert_raise ArgumentError, fn -> Config.new(repo: Fake, prune_limit: -1) end
      assert_raise ArgumentError, fn -> Config.new(repo: Fake, prune_limit: 0) end
      assert_raise ArgumentError, fn -> Config.new(repo: Fake, prune_limit: "5") end
      assert_raise ArgumentError, fn -> Config.new(repo: Fake, prune_limit: 1.0) end

      assert %Config{} = Config.new(repo: Fake, prune_limit: 5_000)
    end

    test ":queues are validated as atom, integer pairs" do
      assert_raise ArgumentError, fn -> Config.new(repo: Fake, queues: %{default: 25}) end
      assert_raise ArgumentError, fn -> Config.new(repo: Fake, queues: [{"default", 25}]) end
      assert_raise ArgumentError, fn -> Config.new(repo: Fake, queues: [default: 0]) end
      assert_raise ArgumentError, fn -> Config.new(repo: Fake, queues: [default: 3.5]) end

      assert %Config{} = Config.new(repo: Fake, queues: [default: 1])
    end

    test ":shutdown_grace_period is validated as an integer" do
      assert_raise ArgumentError, fn -> Config.new(repo: Fake, shutdown_grace_period: -1) end
      assert_raise ArgumentError, fn -> Config.new(repo: Fake, shutdown_grace_period: 0) end
      assert_raise ArgumentError, fn -> Config.new(repo: Fake, shutdown_grace_period: "5") end
      assert_raise ArgumentError, fn -> Config.new(repo: Fake, shutdown_grace_period: 1.0) end

      assert %Config{} = Config.new(repo: Fake, shutdown_grace_period: 10)
    end

    test ":verbose is validated as a boolean" do
      assert_raise ArgumentError, fn -> Config.new(repo: Fake, verbose: 1) end
      assert_raise ArgumentError, fn -> Config.new(repo: Fake, verbose: "false") end
      assert_raise ArgumentError, fn -> Config.new(repo: Fake, verbose: nil) end

      assert %Config{} = Config.new(repo: Fake, verbose: true)
    end
  end

  describe "node_name/1" do
    test "the system's DYNO value is favored when available" do
      assert Config.node_name(%{"DYNO" => "worker.1"}) == "worker.1"
    end

    test "the local hostname is used without a DYNO variable" do
      hostname = Config.node_name()

      assert is_binary(hostname)
      assert String.length(hostname) > 1
    end
  end
end
