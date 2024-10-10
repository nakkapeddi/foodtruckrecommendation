defmodule FoodTruckRecommender.DataLoader do
  alias NimbleCSV.RFC4180, as: CSV
  alias FoodTruckRecommender.{FoodTruck, FoodTruckStore}

  def load_data do 
    "priv/data/Mobile_Food_Facility_Permit.csv" # Can extend this with live data from an API, multiple data sources for different cities...
    |> File.stream!()
    |> CSV.parse_stream()
    |> Stream.map(&parse_row/1)
    |> Enum.each(&FoodTruckStore.insert/1)
  end

  defp parse_row(row) do
    %FoodTruck{
      location_id: Enum.at(row, 0),
      applicant: Enum.at(row, 1),
      facility_type: Enum.at(row, 2),
      cnn: Enum.at(row, 3),
      location_description: Enum.at(row, 4),
      address: Enum.at(row, 5),
      block_lot: Enum.at(row, 6),
      block: Enum.at(row, 7),
      lot: Enum.at(row, 8),
      permit: Enum.at(row, 9),
      status: Enum.at(row, 10),
      food_items: Enum.at(row, 11),
      x: parse_float(Enum.at(row, 12)),
      y: parse_float(Enum.at(row, 13)),
      latitude: parse_float(Enum.at(row, 14)),
      longitude: parse_float(Enum.at(row, 15)),
      schedule: Enum.at(row, 16),
      days_hours: Enum.at(row, 17),
      noi_sent: Enum.at(row, 18),
      approved: Enum.at(row, 19),
      received: Enum.at(row, 20),
      prior_permit: parse_bool(Enum.at(row, 21)),
      expiration_date: Enum.at(row, 22),
      location: Enum.at(row, 23),
      fire_prevention_districts: Enum.at(row, 24),
      police_districts: Enum.at(row, 25),
      supervisor_districts: Enum.at(row, 26),
      zip_codes: Enum.at(row, 27),
      neighborhoods: Enum.at(row, 28)
    }
  end

  defp parse_float(value) do
    case Float.parse(value) do
      {number, _} -> number
      :error -> nil
    end
  end

  defp parse_bool(value) do
    case value do
      "1" -> true
      "0" -> false
      _ -> nil
    end
  end
end