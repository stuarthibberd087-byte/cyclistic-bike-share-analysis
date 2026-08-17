SELECT
  _TABLE_SUFFIX AS month,
  COUNT(*) AS total_rows,
  COUNT(DISTINCT ride_id) AS unique_ride_ids,
  MIN(started_at) AS earliest_start,
  MAX(ended_at) AS latest_end
FROM `cyclistic-capstone-202601.cyclistic_capstone.trips_*`
GROUP BY month
ORDER BY month;
