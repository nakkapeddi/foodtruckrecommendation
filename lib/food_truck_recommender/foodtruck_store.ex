defmodule FoodTruckRecommender.FoodTruckStore do
  use GenServer

  @table_name :food_trucks

  ## Client API

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def insert(food_truck) do
    :ets.insert(@table_name, {food_truck.location_id, food_truck})
  end

  def get_all do
    :ets.tab2list(@table_name)
    |> Enum.map(fn {_key, value} -> value end)
  end

  def get_by_id(location_id) do
    case :ets.lookup(@table_name, location_id) do
      [{^location_id, food_truck}] -> {:ok, food_truck}
      [] -> :not_found
    end
  end

  ## Server Callbacks

  def init(:ok) do
    :ets.new(@table_name, [:set, :public, :named_table])
    {:ok, %{}}
  end
end