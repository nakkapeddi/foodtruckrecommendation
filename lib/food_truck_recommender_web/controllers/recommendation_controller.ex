require Logger

defmodule FoodTruckRecommenderWeb.RecommendationController do
  use FoodTruckRecommenderWeb, :controller

  alias FoodTruckRecommender.FoodTruckStore

  def recommend(conn, %{"preferences" => prefs_params}) do
    preferences = %{
      preferred_cuisine: prefs_params["preferred_cuisine"],
      user_latitude: parse_float(prefs_params["latitude"]),
      user_longitude: parse_float(prefs_params["longitude"]),
      max_distance: parse_float(prefs_params["max_distance"]),
      time: prefs_params["time"]
    }

    recommendations = get_recommendations(preferences)

    json(conn, recommendations)
  end

  defp get_recommendations(preferences) do
    FoodTruckStore.get_all()
    |> Enum.filter(&matches_preferences?(&1, preferences))
  end

  defp matches_preferences?(food_truck, preferences) do
    # Extract and normalize the strings
    food_items = String.downcase(food_truck.food_items || "")
    preferred_cuisine = String.downcase(preferences.preferred_cuisine || "")

    # Debug prints
    Logger.debug("Food Truck Applicant: #{inspect(food_truck.applicant)}")
    Logger.debug("Food Truck Food Items: #{inspect(food_items)}")
    Logger.debug("User Preferred Cuisine: #{inspect(preferred_cuisine)}")

    # Matching logic
    cuisine_match = String.contains?(food_items, preferred_cuisine)

    Logger.debug("Cuisine Match Result: #{inspect(cuisine_match)}")

    distance_match = within_distance?(food_truck, preferences)

    Logger.debug("Distance Match Result: #{inspect(distance_match)}")

    overall_match = cuisine_match and distance_match

    Logger.debug("Overall Match Result: #{inspect(overall_match)}")

    overall_match
  end

  defp within_distance?(food_truck, preferences) do
    with {:ok, truck_lat} <- parse_float(food_truck.latitude),
         {:ok, truck_lon} <- parse_float(food_truck.longitude),
         {:ok, user_lat} <- preferences.user_latitude,
         {:ok, user_lon} <- preferences.user_longitude,
         {:ok, max_distance} <- preferences.max_distance do
      distance = haversine_distance(truck_lat, truck_lon, user_lat, user_lon)
      distance <= max_distance
    else
      _ -> false
    end
  end

  defp haversine_distance(lat1, lon1, lat2, lon2) do
    # Haversine formula implementation
    earth_radius_km = 6371
    delta_lat = deg2rad(lat2 - lat1)
    delta_lon = deg2rad(lon2 - lon1)

    a =
      :math.sin(delta_lat / 2) * :math.sin(delta_lat / 2) +
        :math.cos(deg2rad(lat1)) * :math.cos(deg2rad(lat2)) *
          :math.sin(delta_lon / 2) * :math.sin(delta_lon / 2)

    c = 2 * :math.atan2(:math.sqrt(a), :math.sqrt(1 - a))
    earth_radius_km * c
  end

  defp deg2rad(degrees), do: degrees * (:math.pi / 180)

  defp parse_float(value) when is_float(value), do: {:ok, value}

  defp parse_float(value) when is_binary(value) do
    case Float.parse(value) do
        {number, _} -> {:ok, number}
        :error -> :error
    end
  end

  defp parse_float(_), do: :error
end