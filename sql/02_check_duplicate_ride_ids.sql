SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT ride_id) AS unique_ride_ids,
  COUNT(*) - COUNT(DISTINCT ride_id) AS duplicate_rows
FROM `cyclistic-capstone-202601.cyclistic_capstone.trips_*`;
