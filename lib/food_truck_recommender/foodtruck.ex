defmodule FoodTruckRecommender.FoodTruck do
  @derive Jason.Encoder
  defstruct [
    :location_id,
    :applicant,
    :facility_type,
    :cnn,
    :location_description,
    :address,
    :block_lot,
    :block,
    :lot,
    :permit,
    :status,
    :food_items,
    :x,
    :y,
    :latitude,
    :longitude,
    :schedule,
    :days_hours,
    :noi_sent,
    :approved,
    :received,
    :prior_permit,
    :expiration_date,
    :location,
    :fire_prevention_districts,
    :police_districts,
    :supervisor_districts,
    :zip_codes,
    :neighborhoods
  ]
end